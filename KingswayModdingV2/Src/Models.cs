using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;
namespace KingswayWorkshop;
public static class Json {
 public static readonly JsonSerializerOptions Options = new() { PropertyNamingPolicy=JsonNamingPolicy.CamelCase, WriteIndented=true, UnmappedMemberHandling=JsonUnmappedMemberHandling.Disallow };
 public static T Read<T>(string p) => JsonSerializer.Deserialize<T>(File.ReadAllText(p),Options) ?? throw new Exception("Empty JSON: "+p);
 public static string Text(object o)=>JsonSerializer.Serialize(o,Options);
 public static void Save(string p,object o){Directory.CreateDirectory(Path.GetDirectoryName(p)!);var tmp=p+".tmp";File.WriteAllText(tmp,Text(o));File.Move(tmp,p,true);}
}
public class Manifest {
 public bool MenuTrails {get;set;}=false;
 public Dictionary<string,AudioAsset> Audio {get;set;}=new();
 [JsonRequired] public int SchemaVersion {get;set;}=3;
 [JsonRequired] public string Id {get;set;}="new_mod"; public string Name {get;set;}="New mod"; public string Version {get;set;}="1.0.0"; public int LoadOrder {get;set;}
 public Dictionary<string,string> Assets {get;set;}=new(); [JsonRequired] public List<Enemy> Enemies {get;set;}=new(); public List<StatusVariant> StatusVariants {get;set;}=new();
 public List<SlotOverride> Overrides {get;set;}=new(); public List<CodePatch> Patches {get;set;}=new();
 [JsonIgnore] public string Directory {get;set;}="";
}
public class Enemy {
 public WindowAppearance Appearance {get;set;}=new();
 public string Mode {get;set;}="enemy"; public double ActivationSeconds {get;set;}=2; public string SpawnSound {get;set;}="";public bool SpawnPitchVariance {get;set;}=true; public string Music {get;set;}="";
 public string Id {get;set;}="enemy"; public string Name {get;set;}="New enemy"; public string Description {get;set;}="A hostile enemy."; public string Type {get;set;}="Undead"; public string Rank {get;set;}="Minion"; public string Image {get;set;}="spr_Skeleton";
 public Stats Stats {get;set;}=new(); public Resistance Advanced {get;set;}=new(); public List<ActionNode> Actions {get;set;}=new(){new(){Kind="damage",Mode="weapon"}}; public List<ActionNode> WhenAttacked {get;set;}=new(); public List<GoneTrigger> WhenGone {get;set;}=new(); public List<ActionNode> Periodic {get;set;}=new(); public List<Loot> Loot {get;set;}=new(); public int TreasureRolls {get;set;} public double TreasureChance {get;set;}=100; public List<Encounter> Encounters {get;set;}=new(); public Movement Movement {get;set;}=new(); public List<Component> Components {get;set;}=new(); public string AdvancedGml {get;set;}="";
}
public class Stats { public double MaxHealth {get;set;}=10; public double Defence {get;set;} public double MinDamage {get;set;}=1.5; public double MaxDamage {get;set;}=2.5; public double AttackSpeed {get;set;}=.4; public double Experience {get;set;}=8; public double GoldMin {get;set;}=1; public double GoldMax {get;set;}=2; }
public class Resistance {public double PoisonResistance {get;set;}=90;public double ColdResistance {get;set;}=110;public double BurnResistance {get;set;}=3;}
public class Encounter { public string Pool {get;set;}="grassLowLevel";public double Weight {get;set;}=1; }
public class ActionNode {
 public string Mode {get;set;}=""; public string Basis {get;set;}="fixed"; public string Resource {get;set;}="health"; public string DestinationResource {get;set;}="health";
 public double Lifesteal {get;set;} public string Move {get;set;}=""; public bool WaitForCompletion {get;set;} public double PauseBefore {get;set;} public string ButtonText {get;set;}="Close";
 public double RestoreAfter {get;set;} public string Layer {get;set;}="normal";
 public string WindowBasis {get;set;}="absolute"; public double WindowOffsetX {get;set;} public double WindowOffsetY {get;set;}
 public double WindowMinX {get;set;}=-.25; public double WindowMaxX {get;set;}=.25; public double WindowMinY {get;set;}=-.25; public double WindowMaxY {get;set;}=.25;
 public double WindowDuration {get;set;} public string WindowEasing {get;set;}="linear"; public string WindowBoundary {get;set;}="inherit";
 public string AttackSpeedOperation {get;set;}="set"; public double AttackSpeedValue {get;set;}=.4; public bool ResetAttackProgress {get;set;}
 public double WaitMin {get;set;} public double WaitMax {get;set;} public int Repeat {get;set;}=1; public double Interval {get;set;} public bool OutsideEntry {get;set;} public string Placement {get;set;}="randomXY"; public string WindowPlacement {get;set;}="fixed"; public string StatusOperation {get;set;}="add";
 public string Kind {get;set;}="strike"; public double Chance {get;set;}=100; public double Amount {get;set;}=1; public double Multiplier {get;set;}=1; public double? MinDamage {get;set;} public double? MaxDamage {get;set;}
 public string Target {get;set;}="victim"; public bool PositiveDamageOnly {get;set;} public bool MagicHits {get;set;} public bool DespiteBlocking {get;set;}=true; public bool Blockable {get;set;}=true;
 public string Family {get;set;}="poison"; public string Variant {get;set;}=""; public string Text {get;set;}=""; public string Enemy {get;set;}=""; public string Asset {get;set;}=""; public string Role {get;set;}="summon";
 public string Effect {get;set;}="Nullify"; public string Group {get;set;}="next_attack_damage"; public string Icon {get;set;}=""; public string Operation {get;set;}="shake"; public double X {get;set;}=.5;public double Y {get;set;}=.5;
 public string Condition {get;set;}="positiveDamage"; public double Threshold {get;set;}=50; public double Cooldown {get;set;}=1; public double HealPerMana {get;set;}
 public List<ActionNode> Children {get;set;}=new(); public List<ActionNode> Else {get;set;}=new(); public int PathCount {get;set;}=2; public int PathPoint {get;set;}=1; public string PathShape {get;set;}="line"; public double Bend {get;set;}=.25; public List<ActionPath> MorePaths {get;set;}=new();
}
public class StatusVariant {public string Id {get;set;}="venom";public string Family {get;set;}="poison";public string Name {get;set;}="Venom";public string Icon {get;set;}="";public string Message {get;set;}="";public string Popup {get;set;}="familyDefault";}
public class Loot {public string Name {get;set;}="";public string Item {get;set;}="obj_Item_HealthPotion";public double Chance {get;set;}=100;public int Min {get;set;}=1;public int Max {get;set;}=1;public int MinLevel {get;set;}=1;public int MaxLevel {get;set;}=999;public string Group {get;set;}="";public double Weight {get;set;}=1;public bool Mandatory {get;set;} public bool Cursed {get;set;} public string Enchantment {get;set;}="native";public List<LootBonus> Enchantments {get;set;}=new();public bool DamageOverride {get;set;}public int DamageMin {get;set;}=1;public int DamageMax {get;set;}=2;public bool LevelOverride {get;set;}public int RequiredLevelMin {get;set;}=1;public int RequiredLevelMax {get;set;}=1;public int RequiredStrength {get;set;}public int RequiredAgility {get;set;}public int RequiredIntelligence {get;set;}}
public class LootBonus {public string Stat {get;set;}="strength";public int Amount {get;set;}=1;}
public class FightOptions {[JsonIgnore]public string CommandToken {get;set;}="";[JsonIgnore]public string CommandFile {get;set;}="";public int DisplayWidth {get;set;}=1366;public int DisplayHeight {get;set;}=768;public int GameScale {get;set;}=2;public bool Fullscreen {get;set;}=true;public double ScreenMovement {get;set;}=1;public double? Quickness {get;set;}public string Mode {get;set;}="level";public int Level {get;set;}=10;public bool DieOnReady {get;set;} public bool RandomMusic {get;set;}[JsonIgnore] public string Verify {get;set;}="";[JsonIgnore] public string ClassOverride {get;set;}="";}
public class Component {public string Slot {get;set;}="limb";public string Enemy {get;set;}="";public string Role {get;set;}="limb";public DeathAction DeathAction {get;set;}=new();}
public class DeathAction {public string Kind {get;set;}="damageHead";public double Amount {get;set;} public bool Percent {get;set;}}
public class Movement {public double StartX {get;set;}=.5;public double StartY {get;set;}=.5;public bool RandomMirror {get;set;} public bool LegacySpawnOffset {get;set;} public List<ActionMove> ActionMoves {get;set;}=new();public DragReturn DragReturn {get;set;}=new();public string Shape {get;set;}="path";public string StartMode {get;set;}="fixed";public double Bend {get;set;}=.25;public bool UseGameSpeed {get;set;} public double GameSpeed {get;set;}=1;public string Profile {get;set;}="";public double Intensity {get;set;}=100;public string Interpolation {get;set;}="linear";public int LoopStart {get;set;}=1;public string Boundary {get;set;}="clamp";public bool PauseAttacking {get;set;} public bool PauseStunned {get;set;}=true;public bool PauseMinimized {get;set;}=true;public bool PauseDead {get;set;}=true;public List<Waypoint> Points {get;set;}=new();}
public class Waypoint {public string Shape {get;set;}="line";public double Bend {get;set;}=.25;public string Behavior {get;set;}="target";public double Radius {get;set;}=.1;public double RadiusSpeed {get;set;}=.25;public double LeftSpread {get;set;}=180;public double RightSpread {get;set;}=180;public double Rotation {get;set;} public string Direction {get;set;}="forward";public double X {get;set;}=.5;public double Y {get;set;}=.5;public double Duration {get;set;}=1;public double Speed {get;set;} public double Wait {get;set;} public double Variance {get;set;} public double ControlX {get;set;}=.5;public double ControlY {get;set;}=.5;}
// "When thing dies/disappears": Entity "" is the actor itself, otherwise a project actor ID or a native projectile object.
// Alternating branch paths 3 and up (path 1 is Children, path 2 is Else).
public class ActionPath {public List<ActionNode> Children {get;set;}=new();}
public class GoneTrigger {public string Entity {get;set;}=""; public List<ActionNode> Children {get;set;}=new();}
public class ActionMove {public string Id {get;set;}="move";public string Name {get;set;}="Action Move";public string Mode {get;set;}="variation";public string Entry {get;set;}="first";public double TransitionSpeed {get;set;}=.5;public string Overlap {get;set;}="ignore";public List<Waypoint> Points {get;set;}=new();public ActionNode LegacyPlacement {get;set;}}
// "If dragged": after the player drops a dragged window it travels back to the Base Path.
public class DragReturn {public string Entry {get;set;}="closest";public double TransitionSpeed {get;set;}=.5;}
public class WindowAppearance {public int Size {get;set;}=68;public int Rotation {get;set;} public bool Draggable {get;set;}=true;public string Layer {get;set;}="normal";public int Opacity {get;set;}=10;public bool Trails {get;set;} public string ButtonText {get;set;}="Close";public bool SkyPortrait {get;set;} public string CosmeticStyle {get;set;}="canon";public double AutoClose {get;set;} public bool ShowCloseIndicator {get;set;}}
public class SlotOverride {public string Slot {get;set;}="";public string Enemy {get;set;}="";public Dictionary<string,string> Components {get;set;}=new();}
public class CodePatch {public string Code {get;set;}="";public string Source {get;set;}="";}
public class ValidationError {public string Mod {get;set;}="";public string Enemy {get;set;}="";public string Field {get;set;}="";public object Value {get;set;}="";public string Message {get;set;}="";}
public class Field {public object Value {get;set;} public string Expression {get;set;}="";public string Certainty {get;set;}="dynamic";public string Source {get;set;}="";}
public class ReferenceObject {public string Object {get;set;}="";public string Parent {get;set;}="";public string Kind {get;set;}="";public string DisplayName {get;set;}="";public string Description {get;set;}="";public string Sprite {get;set;}="";public string Icon {get;set;}="";public Dictionary<string,Field> Fields {get;set;}=new();public List<string> Pools {get;set;}=new();public List<string> Dependencies {get;set;}=new();}
public class Pool {public string Name {get;set;}="";public List<string> Members {get;set;}=new();public string Terrain {get;set;}="";public string Time {get;set;}="";public string Bracket {get;set;}="";public string Placement {get;set;}="";}
public class PathProfile {public string Name {get;set;}="";public bool Smooth {get;set;}public bool Closed {get;set;}public List<double[]> Points {get;set;}=new();public List<string> Users {get;set;}=new();}
public class Adapter {public string Slot {get;set;}="";public string Classification {get;set;}="unsafe";public string Reason {get;set;}="Requires individual review and engine test";public List<string> RequiredComponents {get;set;}=new();public List<string> ProtectedEvents {get;set;}=new();public List<string> ReplaceableEvents {get;set;}=new();public List<string> MandatoryEvidence {get;set;}=new();public List<string> Dependencies {get;set;}=new();}
public class Catalog {[JsonIgnore] public HashSet<string> SoundNames {get;set;}=new();[JsonIgnore] public HashSet<string> MusicNames {get;set;}=new();public int Version {get;set;}=2;public string OriginalSha256 {get;set;}="";public List<ReferenceObject> Objects {get;set;}=new();public List<Pool> Pools {get;set;}=new();public List<PathProfile> Paths {get;set;}=new();public List<string> Sprites {get;set;}=new();public List<Adapter> Adapters {get;set;}=new();public string[] NativeStatusFamilies {get;set;}={"poison","cold","burn","stun","curse"};}
