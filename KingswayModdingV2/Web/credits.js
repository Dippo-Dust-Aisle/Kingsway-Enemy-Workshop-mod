'use strict';
// Credit shown at the bottom of the Mod manager. Set-Credits.ps1 fills in the names.
const workshopCreatedBy='Dippo Dust Aisle; using Opus 5.5, Astra 6.';
const renderManagerWithoutCredits=renderManager;
renderManager=function(){
 renderManagerWithoutCredits.apply(this,arguments);
 const credit=document.createElement('p');credit.className='workshop-credit';credit.textContent='Created By: '+workshopCreatedBy;
 $('#content').append(credit);
};
