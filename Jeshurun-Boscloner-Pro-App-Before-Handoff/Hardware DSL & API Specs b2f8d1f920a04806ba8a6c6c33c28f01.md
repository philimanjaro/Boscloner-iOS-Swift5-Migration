# Hardware DSL & API Specs

# DSL Specifications

## Properties

Prefixed with `$`

read: `$property_name?`

write: `$property_name=new_value`

response: `$property_name:property_value`

### Subscriptions (optional, lets discuss this)

replace `$` with `@` to query about subscriptions to a property.

When subscribed to a property, responses will automatically be sent anytime the property changes (except when property is set by a write, since it will already be sent)

read: `@property_name?`

write: `@property_name=true`

response: `@property_name:true` or `@property_name:false`

## Commands

each command will have a fixed amount of parameters and require a response.

Request: 

- No arguments: `command_name()`
- One argument: `command_name(argument)`
- Some arguments: `command_name(positional,args, ...)`

Another option for commands would be to follow a bash style syntax, such as `command_name arg1;` `command_name;` The `;` could be required to be clear that it is a command. 

**Responses**

OK/empty response:`command_name.` 

value Response: `command_name:response`

error response: `command_name!error_msg`

## Notifications

empty notification `^notification_name.`

value notification `^notification_name:notification_value`

error notification `^notification_name!error_msg`

# Properties

## `$battery`

read-only

returns the current battery status as a value 0 - 100

## `$version`

read-only, returns the current firmware version

## `$device`

read-only, returns the device identifier

## `$name`

read/write. the name of the device.

## `$badge_type`

read/write, the type of the currently loaded badge.

## `$badge_id`

read/write. the ID of the currently loaded badge.

## `$badge_data`

read/write. the data of the loaded badge. in the case of bin file, value will be `bin`

## `$state`

read-only

Status enum:

- `standby`
- `search_<lf|hf|auto>`
- `scan_<badge_type>`
- `sim`
- `brute`

# Commands

## `info(0)`

Returns information about the device such as 

- services offered
- battery percentage
- device name
- firmware version
- hardware identifier
- 

## `standby(0)`

Cancels any operation and puts the device state into `standby`. 

**Response**: `standby.`

**Errors**: 

- TBD

## `search(1)`

Stops any existing operations (scan, sim, brute, etc) and starts searching.

While searching, the `^discovered_badge_type` notification will be sent.

**Params**: 

1. search mode: `lf`, `hf`, `auto`

**Response**: `search.`

**Errors**: 

- `unsupported` this command is not supported on the device
- TBD

## `scan(1)`

Stops any existing operations (scan, sim, brute, etc) and starts scanning for cards with the specific type. In the `scan` state, the device will send `^scanned_badge` and `^cracking_badge` notifications when applicable. 

**Params:** 

1. badge type

**Response: `scan.`**

**Errors**: 

- `unsupported` this command is not supported on the device
- TBD

## `sim(0)`

Stops any existing operations (scan, sim, brute, etc) and starts simulating the currently loaded badge

**response**: `sim.`

**Errors:** 

- `unsupported` this command is not supported on the device
- `no_badge`: no badge is loaded
- `invalid_badge`: The loaded badge configuration is invalid.
- `failure`: the hardware was unable to start the simulation
- TBD

## `brute(0)`

Stops any existing operations (scan, sim, brute, etc) and starts brute forcing using the currently loaded badge

**Response**: `brute.`

Errors: 

- `unsupported` this command is not supported on the device
- `invalid_badge_type`: The loaded badge type cannot be brute forced
- `invalid_badge`: the loaded badge is invalid.
- TBD

## `read(1)`

Performs a single read operation

**Params**:

1. badge type

Response: 

- `read.` if no badge was found
- `read:<card_data>` if the badge was found.

Errors: 

- `unsupported` this command is not supported on the device
- `invalid_state`: the hardware is in an invalid state to perform this command.
- `failure` if there was a hardware issue.
- TBD

## `write(0)`

Writes the loaded badge onto a card.

**Response**: `write.`

Errors: 

- `unsupported` this command is not supported on the device
- `no_badge`: there was no loaded badge
- `invalid_badge`: the loaded badge is invalid.
- `invalid_state`: the device is not in the correct state to run this command.
- `not_found`: there was no card in range to write to.
- TBD

## `clear_badge(0)`

Clears the current badge. Cannot be called while in states `sim` or `brute`.

Same as running all of the following commands: `$badge_type=`, `$badge_id=` , `badge_data=`. 

**Errors:**

- `invalid_state`: the device is not in the correct state to run this command.

# Notifications

## `^discovered_badge_type`

When the device is in `search` state, this notification will be sent when a badge type is discovered. 

**value**: badge type Identifier

**Examples**:

- `^discovered_badge_type:iclass`
- `^discovered_badge_type:mifare`

## `^badge_scanned`

When the device is in `scan` state, this notification will be sent when a badge is detected

**value:** badge payload

## `^cracking_badge`

when the device is in `scan` state with a badge type that requires cracking, this notification will be sent when cracking begins. 

If cracking fails, this notification will be sent again with an error message. 

**Errors:**

- `out_of_range`: the device moved out of range while cracking
- `failed` the device failed to crack the badge.

**Examples:**

- `^cracking_badge.`
- `^cracking_badge!out_of_range`

## `^low_battery`

sent when the device is low on power. Contains the current battery level as it's value. 

Examples: 

- `^low_battery:10`

# Constants

## State

- `search`
- `scan`
- `sim`
- `brute`

## Badge Types

- `proxc2`: HID ProxCard II
- `em4100` EM4100
- `iclass` HID iClass SS/Legacy
- `indala` HID Indala
- `mifare` MIFARE classic