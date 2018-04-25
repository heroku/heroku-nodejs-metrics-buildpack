const gc = require("gc-stats")();
const request = require("request");
const { Histogram } = require("measured");
const eventLoopStats = require('./eventLoopStats');

const METRICS_INTERVAL = parseInt(process.env.METRICS_INTERVAL_OVERRIDE, 10) || 20000; // 20 seconds

// Add timers that approximate the delay in the event loop
// const eventLoopMonitor = new EventLoopMonitor();
// eventLoopMonitor.start(EVENT_LOOP_INTERVAL);

// pauseNS is the cumulative GC pause of the node program between GC runs.
// This is reset every metrics submission run.
let pauseNS = 0;

// gcCount is the number of garbage collections that have been observed between
// metrics runs. This is reset every metrics submission run.
let gcCount = 0;

// Collects the event loop ticks, and calculates p50, p95, p99, max
let delay = new Histogram();

// metricsURL is where the runtime metrics will be posted to. This is added
// to dynos by runtime iff the app is opped into the heroku runtime metrics
// beta.
const metricsURL = process.env.HEROKU_METRICS_URL;

// on every garbage collection, update the statistics.
gc.on("stats", stats => {
  gcCount++;

  pauseNS = pauseNS + stats.pause;
});

// every 20 seconds, submit a metrics payload to metricsURL.
setInterval(() => {
  let ticks = eventLoopStats.sense();
  let totalEventLoopTime = ticks.reduce((a, b) => a + b, 0);

  ticks.forEach(tick => delay.update(tick));

  let aa = totalEventLoopTime / METRICS_INTERVAL;

  let { median, p95, p99, max } = delay.toJSON();

  data = {
    counters: {
      "node.gc.collections": gcCount,
      "node.gc.pause.ns": pauseNS
    },
    gauges: {
      "node.eventloop.usage.percent": aa,
      "node.eventloop.delay.ms.median": median,
      "node.eventloop.delay.ms.p95": p95,
      "node.eventloop.delay.ms.p99": p99,
      "node.eventloop.delay.ms.max": max
    }
  };

  // post data to metricsURL
  options = {
    method: "POST",
    uri: metricsURL,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  };

  request(options, (error, resp, body) => {
    if (error !== null) {
      console.log(
        "[fuzzy-rotary-phone] error when trying to submit data: ",
        error
      );
      return;
    }

    if (resp.statusCode !== 200) {
      console.log(
        "[fuzzy-rotary-phone] expected 200 when trying to submit data, got:",
        resp.statusCode
      );
      console.log("[fuzzy-rotary-phone] body:", body);
      return;
    }
  });

  pauseNS = 0;
  gcCount = 0;
  delay.reset();
}, METRICS_INTERVAL);
