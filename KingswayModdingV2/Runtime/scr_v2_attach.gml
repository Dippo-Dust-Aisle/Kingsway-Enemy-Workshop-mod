var head=argument0;var member=argument1;var members=scr_v2_group(head);
member.encounterGroupId=head.encounterGroupId;member.role="limb";member.ownerHeadId=head;member.summonerId=head;member.v2_structural_amount=argument2;member.v2_structural_percent=argument3;
if(ds_list_find_index(members,member)<0)ds_list_add(members,member);
