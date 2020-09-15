var c=Number.parseInt(process.argv[2]);	
console.log('ARRSIZE:'+c);
let arr = Array(c).fill("some string some string some string some string some string some string some string some string some string some string some string some string some string some string some string ");
arr.reverse();
const used = process.memoryUsage();
console.log(`Alloc(rss) ${Math.round(used['rss'] / 1024 / 1024 * 100) / 100} MB`);
console.log(`heapTotal ${Math.round(used['heapTotal'] / 1024 / 1024 * 100) / 100} MB`);
console.log(`heapUsed ${Math.round(used['heapUsed'] / 1024 / 1024 * 100) / 100} MB`);
console.log(`external ${Math.round(used['external'] / 1024 / 1024 * 100) / 100} MB`);
