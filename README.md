# Territory War System

A FiveM resource that adds territory control gameplay for RP servers.

## Features
- 4 customizable territories with unique rewards
- Individual player rewards for capturers
- Organization-based income system
- Real-time capture progress with anti-cheat
- Interactive NPCs and map blips
- Modern UI with progress tracking

## Installation
1. Download and extract to `resources/territory-system`
2. Add `ensure territory-system` to server.cfg
3. Configure items and rewards in config.lua
4. Restart server

## Configuration
Edit `config.lua` to:
- Add/remove territories
- Set capture times (300 seconds = 5 minutes)
- Configure money per hour ($50,000 default)
- Set item rewards for capturers
- Adjust blip colors and locations

## Usage
- Approach territory NPCs to start capture
- Stay within 300m radius and on foot
- First player to complete capture gets items
- Their organization receives hourly income
- **Set waypoint on territory blip on map and open pause menu to view territory info** (info appears bottom-right)

## Requirements
- ESX Framework
- qtarget
- oxmysql (recommended)

## Support
For issues and suggestions, create an issue on GitHub.
