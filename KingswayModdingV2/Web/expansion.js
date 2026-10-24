'use strict';
const testSettings=Object.assign({displayWidth:1366,displayHeight:768,gameScale:2,fullscreen:true,screenMovement:1,overrideQuickness:false,quickness:1.2,useGameSpeed:true,randomMusic:true,chilled:false,paused:false,snap:true,grid:.05},JSON.parse(localStorage.getItem('kingsway-test-settings')||'{}'));
const movementMultipliers=[[.30,'Slow 0.30×'],[.50,'0.50×'],[.75,'0.75×'],[1,'Normal 1.00×'],[1.15,'1.15×'],[1.30,'1.30×'],[1.45,'Extra 1.45×']];
function uniqueEnemyId(){let n=1;while(project.enemies.some(e=>e.id==='enemy_'+n))n++;return 'enemy_'+n;}
function normalizeEnemy(e){e.whenAttacked??=[];e.whenGone??=[];e.mode??='enemy';e.activationSeconds??=2;e.spawnSound??='';e.spawnPitchVariance??=true;e.music??='';Object.assign(e.movement,{shape:e.movement.shape||'path',startMode:e.movement.startMode||'center',bend:e.movement.bend??.25,useGameSpeed:e.movement.useGameSpeed??false,gameSpeed:e.movement.gameSpeed??1});}
const expandedEditor=renderEditor;renderEditor=function(){if(enemy())normalizeEnemy(enemy());expandedEditor();if(!enemy())return;$('#toolbar').prepend(button('−Enemy',removeEnemy,'delete'));numericControls();};
function confirmEnemyRemoval(enemy,refs){
 return new Promise(resolve=>{
  const dialog=document.createElement('dialog');dialog.className='remove-enemy-dialog';
  dialog.setAttribute('aria-labelledby','remove-enemy-title');
  dialog.innerHTML='<h2 id="remove-enemy-title">Are you sure?</h2><p>Remove <strong>'+esc(enemy.name)+'</strong> ('+esc(enemy.id)+')?</p>'+(refs.length?'<p>Also remove references: '+esc(refs.join(', '))+'.</p>':'')+'<p>This removes the enemy from this project. Cancel leaves it unchanged.</p><div class="row"></div>';
  const finish=value=>{dialog.close();dialog.remove();resolve(value);};
  dialog.querySelector('.row').append(button('Cancel',()=>finish(false)),button('Remove enemy',()=>finish(true),'delete'));
  dialog.addEventListener('cancel',event=>{event.preventDefault();finish(false);});document.body.append(dialog);dialog.showModal();dialog.querySelector('button').focus();
 });
}
async function removeEnemy(){const target=project,e=enemy(),refs=[];for(const other of project.enemies){const visit=list=>{for(const a of list){if(a.kind==='spawn'&&a.enemy===e.id)refs.push(other.name+' summon');visit(a.children||[]);visit(a.else||[]);for(const p of a.morePaths||[])visit(p.children||[]);}};visit(other.actions);visit(other.whenAttacked||[]);visit(other.periodic);for(const t of other.whenGone||[])visit(t.children||[]);if(other.components.some(c=>c.enemy===e.id))refs.push(other.name+' component');}if(project.overrides.some(o=>o.enemy===e.id||Object.values(o.components).includes(e.id)))refs.push('boss overrides');if(!await confirmEnemyRemoval(e,refs)||project!==target||!target.enemies.includes(e))return;
 const prune=list=>list.filter(a=>!(a.kind==='spawn'&&a.enemy===e.id)).map(a=>({...a,children:prune(a.children||[]),else:prune(a.else||[]),morePaths:(a.morePaths||[]).map(p=>({children:prune(p.children||[])}))}));project.enemies=project.enemies.filter(x=>x!==e);for(const other of project.enemies)if(other.whenGone)other.whenGone=other.whenGone.filter(t=>t.entity!==e.id);for(const other of project.enemies){other.actions=prune(other.actions);if(other.whenAttacked)other.whenAttacked=prune(other.whenAttacked);for(const t of other.whenGone||[])t.children=prune(t.children||[]);other.periodic=prune(other.periodic);other.components=other.components.filter(c=>c.enemy!==e.id);}project.overrides=project.overrides.filter(o=>o.enemy!==e.id&&!Object.values(o.components).includes(e.id));enemyIndex=Math.min(enemyIndex,Math.max(0,project.enemies.length-1));await save(target);if(project===target)render();}
const expandedIdentity=renderIdentity;renderIdentity=function(){expandedIdentity();const e=enemy(),panel=document.createElement('div');panel.className='panel';panel.innerHTML='<h2>Enemy or hazard</h2><div class="grid two">'+field('Mode','mode','text',['enemy','hazard'])+field('Hazard activation time (seconds)','activationSeconds')+'</div><p>Hazards have a Close button and one action bar. Closing cancels activation. On activation, the window disappears and its delayed actions finish. Hazards give no experience, loot, or corpse.</p>';$('#editor-panel').prepend(panel);audioControls();};
function audioControls(){const target=project,selected=enemy();project.audio??={};const panel=document.createElement('div');panel.className='panel';panel.innerHTML='<h2>Sounds & encounter music</h2><p>The first encounter music starts once and returns to the previous music when combat ends. Sound and music volume settings apply.</p><div class="grid two">'+field('Spawn sound','spawnSound','text',['',...authoring.sounds.map(x=>x.name),...Object.keys(project.audio).filter(k=>project.audio[k].kind==='sound')])+field('Pitch variance (5%; is standard)','spawnPitchVariance','checkbox')+field('Encounter music','music','text',['',...authoring.music,...Object.keys(project.audio).filter(k=>project.audio[k].kind==='music')])+'</div><div class="row" id="audio-import"></div>';$('#editor-panel').append(panel);for(const path of ['spawnSound','music']){const select=panel.querySelector(`[data-field="${path}"]`);if(select)select.closest('label').append(button('Play sound',()=>previewAudio(select.value)),button('Stop',()=>previewAudio('')));}for(const kind of ['sound','music']){const upload=document.createElement('input');upload.type='file';upload.accept=kind==='music'?'.wav,.ogg':'.wav';upload.hidden=true;upload.onchange=async()=>{const f=upload.files[0];if(!f)return;upload.value='';try{await work('Importing '+kind+'…',()=>importForOwner(target,selected,kind==='music'?'music':'spawnSound',f,kind));}catch{}};$('#audio-import').append(upload,button('Import '+(kind==='music'?'music (WAV / Ogg)':'sound (PCM WAV)'),()=>upload.click()));}}
const expandedLoot=renderLoot;renderLoot=function(){expandedLoot();document.querySelectorAll('.loot-row').forEach((row,i)=>{const l=enemy().loot[i],item=catalog.objects.find(x=>x.object===l.item),details=document.createElement('details');details.innerHTML='<summary>Base item stats · before enchantments and level changes</summary><div class="reference-fields">'+Object.entries(item?.fields||{}).filter(([k])=>/damage|defence|require|weight|value|health|mana|strength|agility|intelligence|vitality/i.test(k)).map(([k,v])=>'<div><b>'+esc(k)+'</b>: '+esc(v.value??v.expression)+'<small>'+esc(v.certainty)+'</small></div>').join('')+'</div>';row.append(details);});numericControls();};
const expandedAdvanced=renderAdvanced;renderAdvanced=function(){const target=project;expandedAdvanced();document.querySelectorAll('#variants .node').forEach((node,i)=>{const variant=target.statusVariants[i];node.append(button('Import icon PNG',()=>{const input=document.createElement('input');input.type='file';input.accept='image/png';input.onchange=async()=>{const f=input.files[0];if(!f)return;try{await work('Importing icon…',()=>importForOwner(target,variant,'icon',f));}catch{}};input.click();}));});numericControls();};
function numericControls(){
 const inputs=[...document.querySelectorAll('input[type=number]')];
 for(const input of inputs){
  const key=input.dataset.field||(input.dataset.action?'action.'+input.dataset.action:input.dataset.point?'movement.'+input.dataset.point:input.dataset.loot?'loot.'+input.dataset.loot:input.dataset.pool?'encounters.weight':input.dataset.test?'test.'+input.dataset.test:'');
  let rule=authoring.limits[key]||authoring.limits[key.split('.')[0]+'.default']||{min:0,max:100000,step:.01};
  if(input.dataset.project==='loadOrder')rule={min:-2147483648,max:2147483647,step:1};
  if(input.dataset.component==='amount')rule={min:0,max:input.closest('.node').querySelector('[data-component=percent]').checked?100:100000,step:.01};
  if(input.classList.contains('bonus-amount'))rule={min:Number(input.min)||1,max:Number(input.max),step:1};
  if(input.getAttribute('aria-label')==='Fight level')rule=authoring.limits['test.level'];
  if(key==='movement.loopStart'&&enemy().movement.points.length)rule={...rule,max:enemy().movement.points.length};
  if(key==='action.attackSpeedValue'&&['set','multiply'].includes(input.closest('.node')?.querySelector('[data-action=attackSpeedOperation]')?.value))rule={...rule,min:0};
  // Arrow / spinner steps: attack speed, damage and health 0.1, window X/Y 0.05, repeat interval 0.05, chance 5, waits 0.5.
  const arrow={'stats.attackSpeed':'0.1','action.attackSpeedValue':'0.1','action.x':'0.05','action.y':'0.05','action.windowOffsetX':'0.05','action.windowOffsetY':'0.05','action.windowMinX':'0.05','action.windowMaxX':'0.05','action.windowMinY':'0.05','action.windowMaxY':'0.05','stats.minDamage':'0.1','stats.maxDamage':'0.1','action.minDamage':'0.1','action.maxDamage':'0.1','stats.maxHealth':'0.1','action.interval':'0.05','action.chance':'5','action.waitMin':'0.5','action.waitMax':'0.5'}[key];
  if(arrow&&!input.dataset.arrowStep)input.dataset.arrowStep=arrow;
  input.min=rule.min;input.max=rule.max;input.step=input.dataset.arrowStep||(rule.step===1?'1':'any');input.title=`${rule.min}–${rule.max}${rule.unit?' '+rule.unit:''}`;
  if(input.dataset.checked)continue;input.dataset.checked='1';
  // Arrow keys on a stepped field snap to the step grid: 0.37 goes up to 0.5 and down to 0.
  input.addEventListener('keydown',ev=>{if(!input.dataset.arrowStep||(ev.key!=='ArrowUp'&&ev.key!=='ArrowDown')||ev.ctrlKey||ev.altKey||ev.metaKey)return;const step=Number(input.dataset.arrowStep),v=Number(input.value);if(!(step>0)||!Number.isFinite(v))return;ev.preventDefault();const k=v/step;let next=(ev.key==='ArrowUp'?Math.floor(k+1e-9)+1:Math.ceil(k-1e-9)-1)*step;next=Math.min(Number(input.max===''?Infinity:input.max),Math.max(Number(input.min===''?-Infinity:input.min),next));input.value=String(Math.round(next*1e6)/1e6);input.dispatchEvent(new Event('input',{bubbles:true}));});
  // Raising a minimum above its maximum raises the maximum to match (all min / max pairs).
  input.addEventListener('change',()=>{const partner=minMaxPartner(input);if(partner&&input.value!==''&&partner.value!==''&&Number(input.value)>Number(partner.value)){partner.value=input.value;partner.dispatchEvent(new Event('input',{bubbles:true}));partner.dispatchEvent(new Event('change',{bubbles:true}));}});
  const error=document.createElement('small');error.className='field-error';input.after(error);
  input._checkNumber=()=>{
   input.setCustomValidity('');let msg='';
   const optional=['minDamage','maxDamage'].includes(input.dataset.action);
   if(input.value===''&&!optional)msg='Enter a number.';
   else if(input.value!==''&&(!Number.isFinite(Number(input.value))||Number(input.value)<Number(input.min)||Number(input.value)>Number(input.max)))msg=`Use ${input.min}–${input.max}.`;
   else if(input.validity.stepMismatch&&input.step==='1')msg='Use a whole number.';
   const node=input.closest('.node,.loot-row');
   const pairs=[['waitMin','waitMax'],['windowMinX','windowMaxX'],['windowMinY','windowMaxY'],['minDamage','maxDamage'],['min','max'],['minLevel','maxLevel']];
   for(const [a,b] of pairs){const low=node?.querySelector(`[data-action="${a}"],[data-loot="${a}"]`),high=node?.querySelector(`[data-action="${b}"],[data-loot="${b}"]`);if(high===input&&low?.value!==''&&high.value!==''&&Number(low.value)>Number(high.value))msg='Maximum must be at least minimum.';}
   for(const [a,b] of [['stats.minDamage','stats.maxDamage'],['stats.goldMin','stats.goldMax']]){const low=document.querySelector(`[data-field="${a}"]`);if(input.dataset.field===b&&low?.value!==''&&Number(low.value)>Number(input.value))msg='Maximum must be at least minimum.';}
   input.setCustomValidity(msg);input.classList.toggle('field-invalid',!!msg);error.textContent=msg;
  };
  const checkAll=()=>document.querySelectorAll('input[type=number]').forEach(el=>el._checkNumber?.());
  input.addEventListener('input',checkAll);input.addEventListener('change',checkAll);
 }
 inputs.forEach(input=>input._checkNumber?.());
}
function testControls(container){const box=document.createElement('details');box.className='panel';box.innerHTML='<summary>Preview & playable test settings (saved on this computer)</summary><p>These settings do not change the authored enemy. Default quickness follows the Level Test Mage’s agility at Fight Level; random equipment and class can change it in Random Fight. Override quickness to compare exactly.</p><div class="grid three">'+[['displayWidth','Display width (pixels)'],['displayHeight','Display height (pixels)'],['gameScale','Game scale'],['quickness','Player quickness override']].map(([k,l])=>`<label>${l}<input type="number" data-test="${k}" value="${testSettings[k]}"></label>`).join('')+[['fullscreen','Fullscreen'],['overrideQuickness','Override player quickness'],['useGameSpeed','Use game movement speed (preview)'],['chilled','Preview chilled (half movement speed)'],['stunned','Preview stunned'],['minimized','Preview minimized'],['paused','Pause preview'],['randomMusic','Load random Vanilla Song (playable test)']].map(([k,l])=>`<label class="check"><input type="checkbox" data-test="${k}" ${testSettings[k]?'checked':''}>${l}</label>`).join('')+'</div><p>Fullscreen fills the desktop while the selected resolution defines the rendered game area. Resolutions larger than the desktop fall back to the desktop size. Screen Movement and quickness override also apply in the playable fight. Chilled and Pause are preview controls.</p>';box.querySelectorAll('[data-test]').forEach(input=>input.onchange=()=>{testSettings[input.dataset.test]=input.type==='checkbox'?input.checked:Number(input.value);localStorage.setItem('kingsway-test-settings',JSON.stringify(testSettings));});container.append(box);}
function defaultQuickness(){return 1+(4+Math.floor((fightLevel-1)*3/4))*.025;}

const expandedFightControls=addFightControls;addFightControls=function(){expandedFightControls();if(section!=="movement")testControls($("#content"));};
const expandedReports=renderReports;renderReports=function(){expandedReports();if(lastResult.error){const p=document.createElement("div");p.className="panel";p.innerHTML="<h2>Game error</h2><p>"+esc(lastResult.error)+"</p><p>"+esc(lastResult.context)+"</p><details><summary>Original game output</summary><pre>"+esc(lastResult.details||"No original details captured.")+"</pre></details>";$("#content").prepend(p);}};

const expandedValidate=validate;validate=async function(){await expandedValidate();if(!Array.isArray(lastResult))return;document.querySelectorAll(".backend-error").forEach(x=>x.remove());for(const error of lastResult.filter(e=>e.enemy===enemy()?.id)){const field=error.field.replace(/\.(Max|Min|Attack|Gold|Poison|Cold|Burn|Defence|Experience)/g,m=>m[0]+m[1].toLowerCase()+m.slice(2));let targets=[];if(/^(actions|whenAttacked|periodic|whenGone)/.test(field)){const split=field.lastIndexOf("."),path=field.slice(0,split),key=field.slice(split+1),node=[...document.querySelectorAll("[data-path]")].find(n=>n.dataset.path===path);if(node)targets=[...node.querySelectorAll(`[data-action="${key}"]`)];}else targets=[...document.querySelectorAll("[data-field],[data-loot],[data-point]")].filter(n=>n.dataset.field===field||"loot."+n.dataset.loot===field||"movement."+n.dataset.point===field);for(const target of targets){const msg=document.createElement("small");msg.className="backend-error field-error";msg.textContent=error.message;target.after(msg);}}};

const expandedComponents=renderComponents;renderComponents=function(){expandedComponents();numericControls();document.querySelectorAll('[data-component="percent"]').forEach(input=>input.addEventListener('change',numericControls));};
// Plays a Spawn sound / Encounter music choice in the editor (project audio,
// vanilla Music/*.ogg or native game sounds). An empty key stops playback.
let previewPlayer=null;
async function previewAudio(key){
 if(previewPlayer){previewPlayer.pause();URL.revokeObjectURL(previewPlayer.src);previewPlayer=null;}
 if(!key)return;
 try{const r=await fetch('/api/audio-preview?id='+encodeURIComponent(project?.id||'')+'&key='+encodeURIComponent(key),{headers:{'X-Workshop-Token':token}});if(!r.ok){let message=r.statusText;try{message=(await r.json()).error||message;}catch{}throw Error(message);}
  previewPlayer=new Audio(URL.createObjectURL(await r.blob()));await previewPlayer.play();}
 catch(e){if(typeof toast==='function')toast(e.message);else alert(e.message);}
}
// The maximum field paired with a minimum field (same action / loot row, or the
// Identity stat pair), or null when the input is not a minimum.
function minMaxPartner(input){
 const pairs={waitMin:'waitMax',windowMinX:'windowMaxX',windowMinY:'windowMaxY',minDamage:'maxDamage',min:'max',minLevel:'maxLevel'};
 const fields={'stats.minDamage':'stats.maxDamage','stats.goldMin':'stats.goldMax'};
 if(input.dataset.field&&fields[input.dataset.field])return document.querySelector(`[data-field="${fields[input.dataset.field]}"]`);
 const key=input.dataset.action||input.dataset.loot,attr=input.dataset.action?'action':'loot';
 if(!key||!pairs[key])return null;
 return input.closest('.node,.loot-row')?.querySelector(`[data-${attr}="${pairs[key]}"]`)||null;
}
