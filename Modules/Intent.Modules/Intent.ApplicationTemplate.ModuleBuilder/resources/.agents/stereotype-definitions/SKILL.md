---
name: stereotype-definitions
description: "Create, read, update, and delete stereotype definitions (schema-level) in a designer via run_designer_script."
---

# Stereotype Definitions — schema-level CRUD

> **Scope:** Creating, reading, updating, and deleting stereotype **definitions** (the schema nodes that
> declare a stereotype's name, properties, target rules, lifecycle scripts, etc.).
> This is distinct from **applying** stereotype instances to elements — for that see the designer scripting
> guide §5 (`ensureStereotype` / `addStereotype` / `removeStereotype`).

---

## 1. Accessing definitions

Both `IPackageApi` and `IElementApi` (including folder handles) expose:

```js
pkg.getStereotypeDefinitions()              // all definitions directly under pkg
pkg.getStereotypeDefinition(nameOrId)       // single by name or id; null when none
pkg.hasStereotypeDefinition(nameOrId)       // boolean
pkg.addStereotypeDefinition(name)           // create and return a new IStereotypeDefinitionApi
```

**Folders are elements.** A folder in the designer is an `IElementApi`, so `addStereotypeDefinition`
works on a folder handle obtained via `lookupByName` or `getChild`:

```js
const folder = lookupByName("Stereotypes");    // IElementApi — a folder
const def = folder.addStereotypeDefinition("Http Settings");
```

Do **NOT** use `createElementUnder` or `addChild` to create stereotype definitions.

---

## 2. `IStereotypeDefinitionApi` — full member list

```ts
// Identity
readonly id: string
readonly parentId: string
readonly name: string
readonly comment: string

// Targeting
readonly hint: string
readonly targetMode: StereotypeTargetMode          // "all-elements" | "elements-of-type" | "elements-that-reference" | "filter-function"
readonly targetTypes: string[]                     // element-settings type IDs (when targetMode = "elements-of-type")
readonly targetReferenceTypes: string[]            // element-settings type IDs (when targetMode = "elements-that-reference")
readonly targetFilterFunction: string              // JS function body (when targetMode = "filter-function")

// Behaviour
readonly applyMode: StereotypeApplyMode            // "manually" | "on-element-created" | "always"
readonly isTrait: boolean
readonly allowMultipleApplies: boolean
readonly order: number

// Display
readonly icon: string | null                       // "fa-code", a URL, or a JSON icon model string
readonly displayTextFunction: string
readonly displayIconFunction: string
readonly displayAsText: boolean
readonly displayAsAnnotation: boolean

// Lifecycle scripts
readonly onAppliedScript: string
readonly onChangedScript: string
readonly onRemovedScript: string
readonly validateFunction: string

// Setters (all enum setters accept values case-insensitively)
setName(value: string): void
setComment(value: string): void
setHint(value: string): void
setTargetMode(mode: StereotypeTargetMode): void
setTargetTypes(values: string[]): void             // accepts type NAMES or IDs — names are resolved automatically
setTargetReferenceTypes(values: string[]): void    // same name-or-id resolution
setTargetFilterFunction(value: string): void
setApplyMode(mode: StereotypeApplyMode): void
setIsTrait(value: boolean): void
setAllowMultipleApplies(value: boolean): void
setOrder(value: number): void
setIcon(icon: string | null): void                 // pass null to clear
setDisplayTextFunction(value: string): void
setDisplayIconFunction(value: string): void
setDisplayAsText(value: boolean): void
setDisplayAsAnnotation(value: boolean): void
setOnAppliedScript(value: string): void
setOnChangedScript(value: string): void
setOnRemovedScript(value: string): void
setValidateFunction(value: string): void

// Property CRUD
getProperties(): IStereotypePropertyDefinitionApi[]
getProperty(name: string): IStereotypePropertyDefinitionApi
hasProperty(name: string): boolean
addProperty(name: string): IStereotypePropertyDefinitionApi
removeProperty(name: string): void

delete(): void
```

---

## 3. `IStereotypePropertyDefinitionApi` — full member list

```ts
// Identity
readonly id: string
readonly name: string
readonly comment: string
readonly hint: string

// Control
readonly controlType: StereotypePropertyControlType
readonly defaultValue: string
readonly placeholder: string

// Options (for "select" / "multi-select")
readonly optionsSource: StereotypePropertyOptionsSource
readonly valueOptions: string[]                    // static options (when optionsSource = "options")
readonly lookupTypes: string[]                     // element-settings type IDs (when optionsSource = "lookup-element" | "nested-lookup" | "lookup-children")
readonly lookupChildrenRootFunction: string        // JS function returning root element id (when optionsSource = "lookup-children")

// Function type definition (for "javascript-function")
readonly apiTypeDefinition: StereotypePropertyFunctionTypeDefinition

// Item list (for "item-list")
readonly itemType: string                          // stereotype definition name or ID

// Visibility / validation
readonly isActiveFunction: string
readonly isRequiredFunction: string

// Setters
setName(value: string): void
setComment(value: string): void
setHint(value: string): void
setControlType(value: StereotypePropertyControlType): void   // case-insensitive
setDefaultValue(value: string): void
setPlaceholder(value: string): void
setOptionsSource(value: StereotypePropertyOptionsSource): void  // case-insensitive
setValueOptions(options: string[]): void
setLookupTypes(typeIds: string[]): void
setLookupChildrenRootFunction(value: string): void
setApiTypeDefinition(value: StereotypePropertyFunctionTypeDefinition): void
setItemType(value: string): void                   // accepts stereotype definition name or ID
setIsActiveFunction(value: string): void
setIsRequiredFunction(value: string): void

delete(): void
```

---

## 4. Enum / type values

```ts
type StereotypeTargetMode =
    "all-elements" | "elements-of-type" | "elements-that-reference" | "filter-function";

type StereotypeApplyMode =
    "manually" | "on-element-created" | "always";

type StereotypePropertyControlType =
    "checkbox" | "decimal" | "icon" | "item-list" | "javascript-function" |
    "multi-select" | "number" | "select" | "text-area" | "text-box";

type StereotypePropertyOptionsSource =
    "not-applicable" | "options" | "lookup-element" | "nested-lookup" |
    "lookup-children" | "lookup-stereotype";

type StereotypePropertyFunctionTypeDefinition =
    "association-direct" | "association-macro" |
    "element-direct" | "element-macro" | "element-visual" |
    "mapping-element" | "mapping-macro" |
    "module-settings" | "stereotype-display";
```

---

## 5. Target types

`setTargetTypes()` and `setTargetReferenceTypes()` accept **element-settings type names** (e.g. `"Class"`,
`"Attribute"`) and resolve them to IDs automatically. Pass the name directly — do **not** use
`findElements` to discover a `specializationId`. Valid names come from `get_designer_schema`'s
"Element types" block.

```js
def.setTargetMode("elements-of-type");
def.setTargetTypes(["Class", "Interface"]);   // names resolved → IDs automatically
```

---

## 6. Worked examples

### Create a stereotype definition with two properties

```js
const pkg = lookupPackage("Module");
const def = pkg.addStereotypeDefinition("Http Settings");
def.setTargetMode("elements-of-type");
def.setTargetTypes(["Operation"]);
def.setApplyMode("manually");

const verb = def.addProperty("Verb");
verb.setControlType("select");
verb.setOptionsSource("options");
verb.setValueOptions(["GET", "POST", "PUT", "DELETE"]);
verb.setDefaultValue("GET");

const route = def.addProperty("Route");
route.setControlType("text-box");
route.setHint("Relative route, e.g. `/orders/{id}`");
```

### Update an existing definition

```js
const def = lookupPackage("Module").getStereotypeDefinition("Http Settings");
if (!def.hasProperty("Produces")) {
    def.addProperty("Produces").setControlType("text-box");
}
```

### Delete a property

```js
const def = lookupPackage("Module").getStereotypeDefinition("Http Settings");
def.removeProperty("OldProperty");
```

### Create a definition inside a folder

```js
const folder = lookupByName("Stereotypes");    // folder is an IElementApi
const def = folder.addStereotypeDefinition("Cache Settings");
def.setTargetMode("all-elements");
def.setApplyMode("manually");
```
