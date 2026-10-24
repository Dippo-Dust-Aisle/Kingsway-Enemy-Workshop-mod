'use strict';
// Project settings: "Copy Enemy to Pastebin" puts the selected enemy on the clipboard
// as text, with the uploaded images and sounds it uses embedded; "Paste Enemy" adds
// it to the open project under a new id, re-uploading those files and renaming
// every reference to them. References to other enemies (limbs, summons) keep their
// ids; copy those enemies too, or validation will point them out.
const transferFormat='kingsway-workshop-enemy';
function transferRefs(value,keys,found=new Set()){if(typeof value==='string'){if(keys.has(value))found.add(value);}else if(Array.isArray(value))value.forEach(v=>transferRefs(v,keys,found));else if(value&&typeof value==='object')Object.values(value).forEach(v=>transferRefs(v,keys,found));return found;}
function transferRename(value,map){if(typeof value==='string')return map.has(value)?map.get(value):value;if(Array.isArray(value))return value.map(v=>transferRename(v,map));if(value&&typeof value==='object'){const out={};for(const [k,v] of Object.entries(value))out[k]=transferRename(v,map);return out;}return value;}
function transferBase64(buffer){let s='';const bytes=new Uint8Array(buffer);for(let i=0;i<bytes.length;i+=0x8000)s+=String.fromCharCode(...bytes.subarray(i,i+0x8000));return btoa(s);}
function transferBlob(b64,type){const s=atob(b64),bytes=new Uint8Array(s.length);for(let i=0;i<s.length;i++)bytes[i]=s.charCodeAt(i);return new Blob([bytes],{type});}
async function copyEnemyToClipboard(){
 const source=project,e=enemy();if(!e){toast('Select an enemy first.',true);return;}
 await work('Copying enemy…',async()=>{
  await save(source);
  const images={},audio={};
  for(const key of transferRefs(e,new Set(Object.keys(source.assets||{})))){const r=await fetch('/project-image/'+source.id+'/'+encodeURIComponent(source.assets[key]));if(r.ok)images[key]=transferBase64(await r.arrayBuffer());}
  for(const key of transferRefs(e,new Set(Object.keys(source.audio||{})))){const a=source.audio[key],r=await fetch('/api/audio-preview?id='+encodeURIComponent(source.id)+'&key='+encodeURIComponent(key),{headers:{'X-Workshop-Token':token}});if(r.ok)audio[key]={kind:a.kind,filename:a.originalFilename||a.file||key,data:transferBase64(await r.arrayBuffer())};}
  const text=JSON.stringify({format:transferFormat,version:1,enemy:e,images,audio});
  await navigator.clipboard.writeText(text);
  toast(`Copied ${e.name||e.id} (${Object.keys(images).length} images, ${Object.keys(audio).length} sounds). Open another project and use Paste Enemy.`);
 });
}
async function pasteEnemyFromClipboard(){
 const target=project;let data;
 try{data=JSON.parse(await navigator.clipboard.readText());}catch(e){toast('The clipboard does not hold a copied enemy.',true);return;}
 if(data?.format!==transferFormat||!data.enemy){toast('The clipboard does not hold a copied enemy.',true);return;}
 await work('Pasting enemy…',()=>queueProject(target,async()=>{
  await writeProject(target);
  const names=new Map();
  for(const [key,b64] of Object.entries(data.images||{})){const up=await api('asset?id='+target.id+'&name=portrait',transferBlob(b64,'image/png'),true);target.assets[up.name]=up.file;names.set(key,up.name);}
  for(const [key,a] of Object.entries(data.audio||{})){const name=String(a.filename||key),ext=name.includes('.')?name.slice(name.lastIndexOf('.')).toLowerCase():'.wav';const up=await api('audio?id='+target.id+'&name='+a.kind+'&kind='+a.kind+'&extension='+encodeURIComponent(ext)+'&filename='+encodeURIComponent(name),transferBlob(a.data,'application/octet-stream'),true);(target.audio??={})[up.name]=up.audio;names.set(key,up.name);}
  const copy=transferRename(data.enemy,names);
  copy.id=uniqueEnemyId();
  if(target.enemies.some(x=>x.name===copy.name))copy.name+=' (copy)';
  normalizeEnemy(copy);target.enemies.push(copy);
  await writeProject(target);
  if(project===target){enemyIndex=target.enemies.length-1;render();}
  toast('Pasted '+copy.name+'. Limbs, summons or spawns that point at other enemies need those enemies in this project too.');
 }));
}
const transferSettings=projectSettings;projectSettings=function(){transferSettings();const panel=$('#editor-panel').querySelector('details');if(!panel)return;const row=document.createElement('div');row.className='row project-commands';row.append(button('Copy Enemy to Pastebin',copyEnemyToClipboard),button('Paste Enemy',pasteEnemyFromClipboard));panel.append(row);};
