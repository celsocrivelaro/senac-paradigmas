const file = await Deno.open('/etc/hosts');
const decoder = new TextDecoder('utf-8');
const text = decoder.decode(await Deno.readAll(file));

console.log(text);