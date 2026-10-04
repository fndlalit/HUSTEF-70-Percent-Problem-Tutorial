// Validate persisted tutorial data read-only, rather than trusting AQE's import counter.
const { execFileSync } = require('node:child_process');
const { readdirSync } = require('node:fs');
const path = require('node:path');
const db = '.agentic-qe/memory.db';
function query(sql) {
  return JSON.parse(execFileSync('sqlite3', ['-readonly', '-json', db, sql], { encoding: 'utf8' }) || '[]');
}
const seeds = require('../seed/aqe-seed-patterns.json').patterns;
const patterns = query('SELECT p.name, e.dimension, length(e.embedding) AS bytes FROM qe_patterns p LEFT JOIN qe_pattern_embeddings e ON e.pattern_id = p.id');
for (const seed of seeds) {
  if (!patterns.some(p => p.name === seed.name && p.dimension === 384 && p.bytes > 0)) {
    throw new Error(`Seed pattern missing or unembedded: ${seed.name}. Run prepare-workshop.sh; see TROUBLESHOOTING.md.`);
  }
}
function files(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap(e => {
    const file = path.join(dir, e.name);
    return e.isDirectory() ? files(file) : /\.(ts|tsx)$/.test(e.name) ? [path.resolve(file)] : [];
  });
}
const sourceFiles = files('src');
const indexed = new Set(query("SELECT file_path FROM hypergraph_nodes WHERE type = 'file'").map(r => r.file_path));
for (const file of sourceFiles) {
  if (!indexed.has(file)) throw new Error(`Source file absent from graph: ${file}`);
}
console.log(`${sourceFiles.length} source files indexed; ${seeds.length}/${seeds.length} checkout seed patterns with 384-dimensional embeddings; ${patterns.length} total patterns: OK`);
