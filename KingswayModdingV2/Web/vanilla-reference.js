'use strict';
// Vanilla reference: pick a game enemy with pictures (same chooser as "Choose game
// sprite"), then take its values for the open tab, one at a time or all at once.
// Identity & Stats, Encounters and Loot are supported. Attack actions are native
// GML and are not convertible; Movement already has Native profiles.
let referenceObject='';
const referenceTabs={identity:'Identity & Stats',encounters:'Encounters',loot:'Loot'};
const referenceStats=[['maxHealth','Max health'],['defence','Defence'],['minDamage','Minimum damage'],['maxDamage','Maximum damage'],['attackSpeed','Attack speed'],['experience','Experience'],['goldMin','Minimum gold'],['goldMax','Maximum gold']];
const referenceResistances=[['poisonResistance','Poison resistance'],['coldResistance','Cold resistance'],['burnResistance','Burn resistance']];
function referenceEnemies(){return catalog.objects.filter(x=>x.kind==='enemy');}
function referenceValue(o,key){const f=o.fields?.[key];return f&&f.value!==undefined&&f.value!==null&&f.value!==''?f.value:undefined;}
// Native drops: drops[i,0] is the item (or choose(a, b) of object indexes), drops[i,1]
// is N where the game drops it when round(random(N)) == 0: 100% for N = 0, else 50/N %.
function referenceDrops(o){const drops=[];for(let i=0;i<10;i++){const item=o.fields?.[`drops[${i}, 0]`],rate=o.fields?.[`drops[${i}, 1]`];if(!item)continue;const n=Number(rate?.value)||0,chance=n<=.5?100:Math.round(5000/n)/100;let items=[];if(typeof item.value==='string'&&item.value.startsWith('obj_'))items=[item.value];else{const m=/^choose\((.*)\)$/.exec(item.expression||'');if(m)items=m[1].split(',').map(s=>catalog.objects[Number(s.trim())]?.object).filter(Boolean);}if(items.length)drops.push({slot:i,items,chance});}return drops;}
function referencePools(o){const counts=new Map();for(const p of catalog.pools){const n=p.members.filter(x=>x===o.object).length;if(n>0)counts.set(p.name,n);}return counts;}
function referenceLootRows(drop){return drop.items.map(item=>({item,chance:drop.chance,min:1,max:1,minLevel:1,maxLevel:999,group:drop.items.length>1?'vanilla_'+drop.slot:'',weight:1,mandatory:false,cursed:false,enchantment:'native',enchantments:[]}));}
function referenceTake(apply){apply();scheduleSave();render();}
function referenceTakeAll(apply){if(!confirm('This will replace all the variables in the tab. This cannot be undone.'))return;referenceTake(apply);}
renderReferences=function(){
 const box=$('#references');if(!box)return;box.innerHTML='<h3>Vanilla reference</h3>';
 if(!referenceTabs[section]){box.append(Object.assign(document.createElement('p'),{className:'hint',textContent:section==='movement'?'Use Native profiles for vanilla movement.':section==='actions'?'Vanilla attacks are compiled game code and cannot be copied as actions.':'No vanilla values for this tab.'}));return;}
 const e=enemy(),o=referenceEnemies().find(x=>x.object===referenceObject);
 box.append(button(o?'Change vanilla enemy':'Choose vanilla enemy',()=>openPicker('Choose a vanilla enemy',referenceEnemies(),x=>{referenceObject=x.object;renderReferences();}),'primary'));
 if(!o||!e)return;
 const head=document.createElement('div');head.className='reference-head';head.innerHTML=`${o.icon?`<img src="/catalog/${esc(o.icon)}" alt="">`:''}<div><b>${esc(o.displayName)}</b><small>${esc(o.object)}</small></div>`;box.append(head);
 const list=document.createElement('div');list.className='reference-list';
 const row=(label,shown,take,icon='')=>{const r=document.createElement('div');r.className='reference-row';r.innerHTML=`${icon?`<img src="/catalog/${esc(icon)}" alt="">`:''}<span>${esc(label)}</span><b>${esc(shown)}</b>`;const b=button('Take',take);if(!take)b.disabled=true;r.append(b);list.append(r);};
 let takeAll=null;
 if(section==='identity'){
  const values=[['Name','name',o.displayName],['Description','description',o.description],['Type','type',referenceValue(o,'type')],['Rank','rank',referenceValue(o,'rank')],['Portrait','image',o.sprite]];
  for(const [label,key,v] of values)row(label,v??'(set by game code)',v===undefined||v===null?null:()=>referenceTake(()=>{e[key]=v;}));
  for(const [key,label] of referenceStats){const v=referenceValue(o,key);row(label,v??(o.fields?.[key]?.expression||'Unknown'),typeof v==='number'?()=>referenceTake(()=>{e.stats[key]=v;}):null);}
  for(const [key,label] of referenceResistances){const v=referenceValue(o,key);if(typeof v==='number')row(label,v,()=>referenceTake(()=>{e.advanced??={};e.advanced[key]=v;}));}
  takeAll=()=>{for(const [,key,v] of values)if(v!==undefined&&v!==null)e[key]=v;for(const [key] of referenceStats){const v=referenceValue(o,key);if(typeof v==='number')e.stats[key]=v;}for(const [key] of referenceResistances){const v=referenceValue(o,key);if(typeof v==='number'){e.advanced??={};e.advanced[key]=v;}}};
 }
 if(section==='encounters'){
  const pools=referencePools(o);
  if(!pools.size)list.append(Object.assign(document.createElement('p'),{className:'hint',textContent:'This enemy is not in any random encounter pool (scripted or event only).'}));
  for(const [pool,weight] of pools)row(pool,'weight '+weight,()=>referenceTake(()=>{e.encounters=e.encounters.filter(x=>x.pool!==pool);e.encounters.push({pool,weight});}));
  takeAll=()=>{e.encounters=[...pools].map(([pool,weight])=>({pool,weight}));};
 }
 if(section==='loot'){
  const drops=referenceDrops(o);
  if(!drops.length)list.append(Object.assign(document.createElement('p'),{className:'hint',textContent:'No fixed drops. This enemy\'s loot comes from the shared random treasure tables (set Treasure rolls on the Loot tab to use them).'}));
  for(const d of drops){const names=d.items.map(i=>catalog.objects.find(x=>x.object===i)?.displayName||i);row((d.items.length>1?'One of: ':'')+names.join(' / '),d.chance+'%',()=>referenceTake(()=>{e.loot.push(...referenceLootRows(d));}),catalog.objects.find(x=>x.object===d.items[0])?.icon||'');}
  const special=!!referenceValue(o,'specialTreasure');
  if(special)list.append(Object.assign(document.createElement('p'),{className:'hint',textContent:'Also drops one random treasure for the area level (copied as 1 treasure roll).'}));
  takeAll=()=>{e.loot=drops.flatMap(referenceLootRows);e.treasureRolls=special?1:0;e.treasureChance=100;};
 }
 const all=button('Take all',()=>referenceTakeAll(takeAll));all.title='Replace every value in this tab with '+o.displayName+'\'s';box.append(all,list);
};
// Encounters tab: copy a vanilla enemy's pool weights straight from a drop-down.
const vanillaRenderEncounters=renderEncounters;renderEncounters=function(){vanillaRenderEncounters();const panel=$('#editor-panel .panel');if(!panel)return;const label=document.createElement('label');label.textContent='Copy encounters from a vanilla enemy';const select=document.createElement('select');select.innerHTML='<option value="">Choose an enemy…</option>'+referenceEnemies().map(o=>`<option value="${esc(o.object)}">${esc(o.displayName)} (${esc(o.object)})</option>`).join('');select.onchange=()=>{const o=referenceEnemies().find(x=>x.object===select.value);if(!o)return;if(!confirm('This will replace all the variables in the tab. This cannot be undone.')){select.value='';return;}enemy().encounters=[...referencePools(o)].map(([pool,weight])=>({pool,weight}));scheduleSave();render();};label.append(select);panel.querySelector('p')?.after(label);};
