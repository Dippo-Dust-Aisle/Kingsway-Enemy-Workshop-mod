'use strict';
// A project keeps one live object for the lifetime of this editor. Network
// responses acknowledge snapshots; they must never replace that live object.
const projectSaves=new WeakMap(),selectionVersions=new WeakMap(),callbackDrafts=new Map();
let portraitTarget;
function saveState(target){
 if(!projectSaves.has(target))projectSaves.set(target,{ack:null,timer:null,tail:Promise.resolve(),pending:0,error:null});
 return projectSaves.get(target);
}
function showSaveState(){
 const badge=document.querySelector('#save-state');if(!badge||!project)return;
 const state=saveState(project),dirty=state.ack!==JSON.stringify(project);
 badge.textContent=state.error?'Save failed · retry':state.pending?'Saving…':dirty?'Unsaved edits':'Saved locally';
 badge.dataset.state=state.error?'error':state.pending||dirty?'pending':'saved';
 badge.title=state.error?.message||'Each project saves independently. Save now retries any failed save.';
}
function queueProject(target,operation){
 const state=saveState(target);state.pending++;showSaveState();
 const result=state.tail.then(operation).then(value=>{state.error=null;return value;},error=>{state.error=error;throw error;}).finally(()=>{state.pending--;showSaveState();});
 // A failed request leaves the edits in memory and does not poison the queue.
 state.tail=result.catch(()=>{});return result;
}
async function writeProject(target){
 const state=saveState(target),snapshot=JSON.stringify(target);
 if(state.ack===snapshot)return;
 await api('save',JSON.parse(snapshot));state.ack=snapshot;
}
function scheduleSave(target=project){
 if(!target)return;const state=saveState(target);clearTimeout(state.timer);
 state.timer=setTimeout(()=>{state.timer=null;save(target).catch(e=>toast(e.message,true));},1000);showSaveState();
}
function save(target=project){
 if(!target)return Promise.resolve();const state=saveState(target);clearTimeout(state.timer);state.timer=null;
 return queueProject(target,()=>writeProject(target));
}
function switchProject(next){
 const previous=project;if(previous)save(previous).catch(e=>toast(e.message,true));
 project=next;enemyIndex=0;view='editor';render();
}
async function refresh(){
 const [incoming,nextStatus]=await Promise.all([api('projects'),api('status')]);
 // Existing objects may have newer edits than this read, even if a save has
// completed since the read started. Keep them, including their nested arrays.
 for(const item of incoming)if(!projects.some(p=>p.id===item.id)){projects.push(item);saveState(item).ack=JSON.stringify(item);}
 status=nextStatus;if(!project)project=projects[0];render();
}
function nextSelection(owner,field){
 let versions=selectionVersions.get(owner);if(!versions)selectionVersions.set(owner,versions={});
 return versions[field]=(versions[field]||0)+1;
}
function choosePortrait(target,selected,image){
 nextSelection(selected,'image');selected.image=image;scheduleSave(target);if(project===target&&enemy()===selected)renderPreview();
}
function selectPortraitFile(target,selected){portraitTarget={target,selected};$('#png-file').value='';$('#png-file').click();}
async function importForOwner(target,owner,field,file,kind='image'){
 const version=nextSelection(owner,field),state=saveState(target);clearTimeout(state.timer);state.timer=null;
 return queueProject(target,async()=>{
  await writeProject(target);
  const endpoint=kind==='image'?'asset?id='+target.id+'&name='+ (field==='image'?'portrait':'icon'):'audio?id='+target.id+'&name='+kind+'&kind='+kind+'&extension='+encodeURIComponent(file.name.slice(file.name.lastIndexOf('.')).toLowerCase())+'&filename='+encodeURIComponent(file.name);
  const uploaded=await api(endpoint,file,true);
  // Merge only the new asset. The owner and all edits made while uploading
  // remain live. A later native choice or upload takes precedence.
  if(kind==='image')target.assets[uploaded.name]=uploaded.file;
  else (target.audio??={})[uploaded.name]=uploaded.audio;
  const present=target.enemies.includes(owner)||target.statusVariants.includes(owner);
  if(present&&selectionVersions.get(owner)?.[field]===version)owner[field]=uploaded.name;
  await writeProject(target);if(project===target)render();
 });
}
function pendingProjectEdits(){return projects.some(p=>{const s=saveState(p);return s.pending||s.ack!==JSON.stringify(p);});}
window.addEventListener('beforeunload',event=>{if(pendingProjectEdits()||callbackDrafts.size){event.preventDefault();event.returnValue='';}});
document.addEventListener('visibilitychange',()=>{if(document.visibilityState==='hidden')for(const p of projects)if(saveState(p).ack!==JSON.stringify(p))save(p).catch(e=>toast(e.message,true));});
// "Upload From Paste": uses the image on the clipboard as the portrait. Larger
// images are shrunk to fit the portrait box (68 x 68; 97 x 99 with Sky Monster
// Portrait; the chosen square for Cosmetics), by a whole-number factor when
// possible so pixel art stays crisp.
async function pastePortrait(target,selected){
 let blob=null;
 try{for(const item of await navigator.clipboard.read()){const type=item.types.find(t=>t.startsWith('image/'));if(type){blob=await item.getType(type);break;}}}
 catch(e){toast('Could not read the clipboard: '+e.message,true);return;}
 if(!blob){toast('The clipboard has no image. Copy an image first.',true);return;}
 const bitmap=await createImageBitmap(blob);
 const a=selected.appearance||{},fitW=selected.mode==='cosmetic'?(a.size||68):a.skyPortrait?97:68,fitH=selected.mode==='cosmetic'?(a.size||68):a.skyPortrait?99:68;
 let scale=Math.min(1,fitW/bitmap.width,fitH/bitmap.height);
 if(scale<1){const whole=Math.ceil(1/scale);if(bitmap.width/whole<=fitW&&bitmap.height/whole<=fitH)scale=1/whole;}
 const w=Math.max(1,Math.floor(bitmap.width*scale)),h=Math.max(1,Math.floor(bitmap.height*scale));
 const canvas=document.createElement('canvas');canvas.width=w;canvas.height=h;const ctx=canvas.getContext('2d');ctx.imageSmoothingEnabled=scale!==1&&!Number.isInteger(1/scale);ctx.drawImage(bitmap,0,0,w,h);
 const png=await new Promise(r=>canvas.toBlob(r,'image/png'));
 const file=new File([png],'pasted.png',{type:'image/png'});
 try{await work('Importing pasted portrait…',()=>importForOwner(target,selected,'image',file));if(scale<1)toast(`Pasted image shrunk to ${w} × ${h} to fit the portrait.`);}catch{}
}
