'use strict';
// Store serialized manifest data, never a reference into a live project. The
// clipboard belongs to this page and is intentionally absent from saved data.
function createActionClipboard(){
 let snapshot=null;
 return {
  get hasAction(){return snapshot!==null;},
  copy(action){snapshot=JSON.stringify(action);},
  paste(list,selected,below=false){
   const index=list.indexOf(selected);
   if(snapshot===null||index<0)return false;
   list.splice(index+(below?1:0),0,JSON.parse(snapshot));return true;
  },
  // Replace the selected action (and everything inside it) with the copied one.
  replace(list,selected){
   const index=list.indexOf(selected);
   if(snapshot===null||index<0)return false;
   list.splice(index,1,JSON.parse(snapshot));return true;
  }
 };
}
const actionClipboard=createActionClipboard();
if(typeof module!=='undefined')module.exports={createActionClipboard};
