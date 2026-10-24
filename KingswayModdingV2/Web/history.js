'use strict';
// Workshop-wide undo / redo for every tab. Every edit already calls scheduleSave(); a burst
// of edits (typing, dragging a point) becomes one step once it has been idle for 600 ms.
// Ctrl+Z undoes, Ctrl+Y or Ctrl+Shift+Z redoes (not while typing in a field).
const editHistory=new WeakMap();
function historyOf(p){
 let h=editHistory.get(p);
 if(!h)editHistory.set(p,h={undo:[],redo:[],base:saveState(p).ack||JSON.stringify(p),burst:null,restoring:false});
 return h;
}
function endEditBurst(p){
 const h=historyOf(p);clearTimeout(h.burst);h.burst=null;
 const now=JSON.stringify(p);h.base=now;
 if(h.undo.length&&h.undo[h.undo.length-1]===now)h.undo.pop(); // the burst changed nothing
 updateHistoryButtons();
}
const scheduleSaveWithoutHistory=scheduleSave;
scheduleSave=function(target=project){
 if(target){
  const h=historyOf(target);
  if(!h.restoring){
   if(!h.burst){h.undo.push(h.base);if(h.undo.length>100)h.undo.shift();h.redo.length=0;}
   clearTimeout(h.burst);h.burst=setTimeout(()=>endEditBurst(target),600);
  }
 }
 scheduleSaveWithoutHistory(target);updateHistoryButtons();
};
function historyStep(back){
 const p=project;if(!p)return;const h=historyOf(p);if(h.burst)endEditBurst(p);
 const from=back?h.undo:h.redo,to=back?h.redo:h.undo;if(!from.length)return;
 to.push(JSON.stringify(p));const state=from.pop();h.base=state;
 // Restore in place: the project object stays the same, so saving and selection keep working.
 const data=JSON.parse(state);for(const k of Object.keys(p))delete p[k];Object.assign(p,data);
 enemyIndex=Math.max(0,Math.min(enemyIndex,p.enemies.length-1));
 h.restoring=true;try{scheduleSaveWithoutHistory(p);}finally{h.restoring=false;}
 render();toast(back?'Undone':'Redone');
}
function updateHistoryButtons(){
 const h=project&&historyOf(project),u=$('#undo-button'),r=$('#redo-button');
 if(u)u.disabled=!h?.undo.length&&!h?.burst;if(r)r.disabled=!h?.redo.length;
}
const renderWithoutHistory=render;
render=function(){
 renderWithoutHistory.apply(this,arguments);
 const state=$('#save-state');
 if(state&&!$('#undo-button')){
  const u=button('↶ Undo',()=>historyStep(true)),r=button('↷ Redo',()=>historyStep(false));
  u.id='undo-button';r.id='redo-button';u.title='Undo (Ctrl+Z)';r.title='Redo (Ctrl+Y)';state.before(u,r);
 }
 updateHistoryButtons();markSelectedAction();
};

// Keyboard: click an action (or a When thing dies/disappears trigger) to select it, then
// Ctrl+Up / Ctrl+Down moves it, Ctrl+Left collapses it and Ctrl+Right expands it.
let selectedActionPath='';
function resolveActionPath(path){
 let owner=enemy(),list=null,index=-1;
 for(const [,name,i] of path.matchAll(/([A-Za-z]+)\[(\d+)\]/g)){if(!owner)return null;list=owner[name];index=Number(i);if(!Array.isArray(list)||index>=list.length)return null;owner=list[index];}
 return list?{list,index,item:list[index]}:null;
}
function markSelectedAction(){
 document.querySelectorAll('.kb-selected').forEach(x=>x.classList.remove('kb-selected'));
 if(!selectedActionPath)return null;
 const node=[...document.querySelectorAll('[data-path]')].find(x=>x.dataset.path===selectedActionPath&&(x.classList.contains('action-node')||x.classList.contains('gone-trigger')));
 node?.classList.add('kb-selected');return node;
}
document.addEventListener('pointerdown',ev=>{
 const node=ev.target.closest?.('.action-node,.gone-trigger');
 selectedActionPath=node?node.dataset.path:'';markSelectedAction();
},true);
const renderActionsWithoutSelection=renderActions;
renderActions=function(){renderActionsWithoutSelection.apply(this,arguments);markSelectedAction();};
document.addEventListener('keydown',ev=>{
 if(!(ev.ctrlKey||ev.metaKey)||ev.altKey)return;
 const t=ev.target,typing=t&&(t.tagName==='TEXTAREA'||t.tagName==='SELECT'||t.isContentEditable||(t.tagName==='INPUT'&&!['checkbox','radio','button','submit'].includes(t.type)));
 if(typing)return; // fields keep their own undo and word-jumping
 const key=ev.key.toLowerCase();
 if(key==='z'||key==='y'){if(view!=='editor')return;ev.preventDefault();historyStep(key==='z'&&!ev.shiftKey);return;}
 if(!['arrowup','arrowdown','arrowleft','arrowright'].includes(key)||!selectedActionPath||view!=='editor'||section!=='actions')return;
 const at=resolveActionPath(selectedActionPath);if(!at)return;ev.preventDefault();
 if(key==='arrowup'||key==='arrowdown'){
  const to=at.index+(key==='arrowup'?-1:1);if(to<0||to>=at.list.length)return;
  [at.list[at.index],at.list[to]]=[at.list[to],at.list[at.index]];
  selectedActionPath=selectedActionPath.replace(/\[\d+\]$/,'['+to+']');scheduleSave();
 }else if(selectedActionPath.startsWith('whenGone[')&&!selectedActionPath.includes('.'))return; // triggers do not collapse
 else if(key==='arrowleft')collapsedActions.add(at.item);else collapsedActions.delete(at.item);
 renderActions();markSelectedAction()?.scrollIntoView({block:'nearest'});
});
