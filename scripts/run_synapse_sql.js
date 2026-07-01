const fs = require("fs");
const { Connection, Request } = require("tedious");

const [, , file, database = "master"] = process.argv;

if (!file) {
  console.error("Usage: node scripts/run_synapse_sql.js <sql-file> [database]");
  process.exit(1);
}

for (const name of ["SYNAPSE_SQL_ADMIN_PASSWORD"]) {
  if (!process.env[name]) {
    console.error(`Missing ${name}`);
    process.exit(1);
  }
}

const config = {
  server: "synw-aso-analytics-wora-ondemand.sql.azuresynapse.net",
  authentication: {
    type: "default",
    options: {
      userName: "synadmin",
      password: process.env.SYNAPSE_SQL_ADMIN_PASSWORD,
    },
  },
  options: {
    database,
    encrypt: true,
    trustServerCertificate: false,
    rowCollectionOnRequestCompletion: true,
    requestTimeout: 120000,
    connectTimeout: 30000,
  },
};

const sql = fs.readFileSync(file, "utf8");
const batches = sql
  .split(/^\s*GO\s*$/gim)
  .map((batch) => batch.trim())
  .filter(Boolean);

function connect() {
  return new Promise((resolve, reject) => {
    const connection = new Connection(config);
    connection.on("connect", (err) => (err ? reject(err) : resolve(connection)));
    connection.connect();
  });
}

function execute(connection, batch) {
  return new Promise((resolve, reject) => {
    const request = new Request(batch, (err, rowCount, rows) => {
      if (err) return reject(err);
      for (const row of rows || []) {
        console.log(row.map((col) => `${col.metadata.colName}=${col.value}`).join("\t"));
      }
      if (rowCount !== undefined) console.log(`rows=${rowCount}`);
      resolve();
    });
    connection.execSql(request);
  });
}

(async () => {
  const connection = await connect();
  try {
    for (const batch of batches) {
      console.log(`-- running: ${batch.split(/\r?\n/).find((line) => line.trim())?.slice(0, 100)}`);
      await execute(connection, batch);
    }
  } finally {
    connection.close();
  }
})().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});

