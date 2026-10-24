using System;
using System.Linq;
using System.Text.Json;
namespace KingswayWorkshop;
public sealed record EnchantmentChoice(string Id,string Name,string Unit,int Max=1000);
public static class Enchantments {
 public static readonly EnchantmentChoice[] Choices={
  new("strength","Strength","points"),new("vitality","Vitality","points"),new("intelligence","Intellect","points"),new("agility","Agility","points"),
  new("damage","Physical damage","points"),new("defence","Defence","points"),new("magicPowerPercent","Magic power","%"),new("poisonResist","Poison resistance","%",100),
  new("healthRegeneration","Health regeneration","points"),new("moveSpeed","Movement speed","points"),new("maxTravelDistance","Travel distance","points"),
  new("escapeChance","Escape chance","%",100),new("magicFind","Magic find","%",100),new("attackSpeed","Attack speed","%"),new("criticalDamage","Critical damage","%"),
  new("criticalChance","Critical chance","%",100),new("damageToUndead","Damage to undead","%"),new("damageToDemons","Damage to demons","%"),new("damageToBeasts","Damage to beasts","%"),
  new("damageToMinions","Damage to minions","%"),new("damageToElites","Damage to bosses","%"),new("protectionPercent","Damage protection","%",100),
  new("goldFindPercent","Gold find","%"),new("vampirismPercent","Life steal","%",100),new("poisonOnAttack","Poison on attack","points"),new("chillOnAttack","Chill on attack","points"),new("stunOnAttack","Stun on attack","points")
 };
 public static string Value(ReferenceObject item,string field)=>item.Fields.TryGetValue(field,out var v)?(v.Value is JsonElement j?j.ToString():v.Value?.ToString())??"":"";
 public static bool Supported(ReferenceObject item)=>item!=null&&new[]{"Weapon","Chest","Head","Feet","Offhand","Ring","Charm"}.Contains(Value(item,"itemType"))&&item.Fields.ContainsKey("chanceToEnchant");
 public static string[] Existing(ReferenceObject item)=>Enumerable.Range(0,9).Select(i=>Value(item,"bonus["+i+", 0]")).Where(x=>x!="").Distinct().ToArray();
}
