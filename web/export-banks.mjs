import {readFileSync,writeFileSync} from 'node:fs';
// Export the actual Swift editorial groups; fail rather than silently dropping a bank.
const source=readFileSync(new URL('../Tusmo/Mots.swift',import.meta.url),'utf8');
const section=source.split('static let groupesParTheme:')[1].split('static func poidsParTheme')[0];
const banks=[];
for(const m of section.matchAll(/"([^"\n]+)":\s*(\[[\s\S]*?\n        \])/g)){
 const groups=JSON.parse(m[2].replace(/,\s*]/g,']'));
 if(groups.length!==5)throw Error(m[1]);
 banks.push({id:'theme.'+m[1],name:m[1],groups});
}
const pokemon=readFileSync(new URL('../Tusmo/Pokemon.swift',import.meta.url),'utf8').split('private var motsParNiveau:')[1].split('/// Liste aplatie')[0];
let gen=0;
for(const m of pokemon.matchAll(/return (\[[\s\S]*?\n            \])/g)) banks.push({id:'pokemon.generation.'+(++gen),name:'Pokémon · Génération '+gen,groups:JSON.parse(m[1].replace(/,\s*]/g,']'))});
if(banks.length!==27||gen!==9)throw Error('Banques manquantes');
const emojis=['🏀','🎵','🎤','🍕','🐾','✈️','🏙️','🎬','🎓','💻','📱','🌳','🏠','🍩','🏔️','🍎','🌍','🛋️'];
banks.forEach((b,i)=>{b.emoji=emojis[i]||'⚡';if(new Set(b.groups.flat()).size!==b.groups.flat().length)throw Error('Doublon '+b.name)});
const seen=new Set();const mixed=[[],[],[],[],[]];
for(const b of banks.slice(0,18))b.groups.forEach((g,i)=>g.forEach(w=>{if(!seen.has(w)){mixed[i].push(w);seen.add(w)}}));
banks.push({id:'theme.Mélange',name:'Mélange',emoji:'🎲',groups:mixed});
writeFileSync(new URL('./public/banks.json',import.meta.url),JSON.stringify(banks));
console.log(`${banks.length} banques exportées`);
