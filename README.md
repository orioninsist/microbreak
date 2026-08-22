# Microbreak

A lightweight Linux health reminder daemon that helps you maintain healthy computer habits through timed breaks, focus sessions, Pomodoro workflow, voice notifications, desktop notifications, and automatic screen rest.

Microbreak is designed to run quietly in the background and become part of your daily computer workflow. After installation, it starts automatically with your user session and manages break reminders without requiring manual interaction.

---

## Features

### Focus Mode

Track focused work sessions with automatic completion handling.

Features:

- Configurable focus duration
- Automatic break trigger
- Voice feedback
- Desktop notifications
- Statistics tracking

---

### Pomodoro Mode

A complete Pomodoro workflow.

Features:

- Work sessions
- Break sessions
- Multiple cycles
- Voice announcements
- Desktop notifications
- Cycle statistics

Example:

```

25 minutes work
|
v
5 minutes break
|
v
Repeat 4 cycles

```

---

### Screen Rest

Protect your eyes during long computer sessions.

When a break starts:

1. Voice reminder is played
2. Screen turns off automatically
3. User rests
4. Screen turns back on
5. Completion notification is sent

Works with Wayland/Sway using:

```

swaymsg DPMS

```

---

### Voice Support

Powered by Piper TTS.

Example:

```

Please take a screen break

```

Microbreak supports natural voice reminders using local offline text-to-speech.

No cloud service required.

---

### Desktop Notifications

Uses Linux desktop notifications:

```

notify-send

```

Examples:

```

Focus completed

Pomodoro completed

Please take a screen break

```

---

### Statistics

Tracks daily usage:

Example:

```

focus_sessions=5
pomodoro_cycles=3
screen_rests=8

```

Stored locally:

```

~/.local/state/microbreak/statistics

```

---

## Automatic Startup

Microbreak uses a systemd user service.

After enabling:

```

systemd user service
|
v
login
|
v
microbreak daemon starts
|
v
automatic reminders

```

No terminal session is required.

The computer starts, the user logs in, and Microbreak continues running automatically.

---

## Daily Usage Scenario

Typical workflow:

### Morning

User turns on the computer.

```

Login
|
v
systemd starts microbreak.service
|
v
Microbreak daemon running

```

No manual command needed.

---

### Working Session

User starts working.

Microbreak runs silently:

```

Focus session
|
v
Timer running
|
v
Focus completed

```

User receives:

- Notification
- Voice message
- Break reminder

---

### Screen Break

After long usage:

```

Time for a break
|
v
Voice reminder
|
v
Screen off
|
v
Rest period
|
v
Screen on

````

The user can rest their eyes without manually checking time.

---

## Installation

Clone the repository:

```bash
git clone <repository-url>
cd microbreak
````

Make the launcher executable:

```bash
chmod +x microbreak
```

Enable the systemd user service:

```bash
systemctl --user enable microbreak.service
```

Start:

```bash
systemctl --user start microbreak.service
```

---

## Commands

Show help:

```bash
microbreak --help
```

or:

```bash
microbreak -h
```

Show version:

```bash
microbreak --version
```

---

### Service Control

Start:

```bash
microbreak start
```

Stop:

```bash
microbreak stop
```

Restart:

```bash
microbreak restart
```

---

### Focus

Start focus mode:

```bash
microbreak focus start
```

Check status:

```bash
microbreak focus status
```

Stop:

```bash
microbreak focus stop
```

---

### Pomodoro

Start:

```bash
microbreak pomodoro start
```

Status:

```bash
microbreak pomodoro status
```

Stop:

```bash
microbreak pomodoro stop
```

---

### Screen Rest

Manual test:

```bash
microbreak screen-rest
```

---

### Configuration

Show configuration:

```bash
microbreak config
```

Configuration file:

```
config/microbreak.conf
```

Example:

```ini
focus_duration=25

pomodoro_work_duration=25
pomodoro_break_duration=5
pomodoro_cycles=4

screen_rest_seconds=20

voice_enabled=true
screen_rest=true
statistics=true
```

---

## System Requirements

Recommended environment:

* Linux
* Bash
* systemd user session
* Wayland
* Sway compositor (for automatic screen control)
* Piper TTS
* notify-send

---

## Architecture

Microbreak follows a modular shell architecture.

```
microbreak

core/
 ├── daemon.sh
 ├── timer.sh
 └── config_loader.sh


features/
 ├── focus.sh
 ├── pomodoro.sh
 ├── screen_rest.sh
 ├── voice.sh
 ├── notification.sh
 └── statistics.sh


systemd/
 └── microbreak.service
```

Each feature is isolated and can be extended independently.

---

## Design Goals

Microbreak focuses on:

* Minimal resource usage
* Offline operation
* Modular Bash architecture
* Automatic background operation
* Healthy computer habits
* Simple daily workflow

---

## Daily Workflow Scenario

Microbreak combines three health and productivity features into one automatic workflow:

```

Computer startup
|
v
systemd starts Microbreak daemon
|
v
Focus Mode
|
v
Pomodoro Mode
|
v
Screen Rest

```

### Example Daily Session

The user starts the computer and begins working.

Microbreak runs silently in the background.

```

Focus Mode
|
v
25 minutes of focused work
|
v
Focus completed
|
v
Notification + Voice reminder

```

After completing work sessions, Pomodoro continues the workflow:

```

Pomodoro Mode
|
v
Work session
|
v
Short break
|
v
Repeat cycles

```

During long computer usage, Screen Rest protects the user's eyes:

```

Screen Rest
|
v
Break reminder
|
v
Voice notification
|
v
Screen turns off
|
v
Rest period
|
v
Screen turns on

```

Complete daily flow:

```

Start computer
|
v
Microbreak daemon starts automatically
|
v
Focus Mode helps maintain concentration
|
v
Pomodoro Mode organizes work cycles
|
v
Screen Rest protects eye health
|
v
Statistics record daily activity

```

Microbreak combines productivity and health protection into a single lightweight background service.

---
 
 ## Real Daily Usage Scenario

After restarting the computer:

```

Computer starts
|
v
User logs in
|
v
systemd automatically starts Microbreak daemon
|
v
Configuration is loaded
|
v
Enabled features become active

```

Current configuration:

```

Focus Mode: true
Pomodoro Mode: true
Screen Rest: true

```

This means all three systems are ready.

---

### 1. Focus Mode

The user starts a focus session:

```

microbreak focus start

```

Microbreak starts the focus timer.

Example:

```

Focus started
|
v
25 minutes working
|
v
Focus completed
|
v
Notification + Voice reminder
|
v
Statistics updated

```

---

### 2. Pomodoro Mode

The user can start a Pomodoro workflow:

```

microbreak pomodoro start

```

Microbreak manages:

```

Work session
|
v
Break session
|
v
Next cycle
|
v
Completed cycles saved

```

Example:

```

25 minutes work
5 minutes break
Repeat 4 cycles

```

---

### 3. Screen Rest

During long computer usage:

```

Timer completed
|
v
Screen Rest starts
|
v
Voice reminder
|
v
Desktop notification
|
v
Screen turns off
|
v
Rest period
|
v
Screen turns on

```

---

### Normal User Experience

After the first setup, the user does not need to manually manage Microbreak.

Every day:

```

Computer ON
|
v
Microbreak starts automatically
|
v
Work normally
|
v
Focus reminders
|
v
Pomodoro sessions
|
v
Automatic screen breaks
|
v
Daily statistics saved
```
 
 



## License

MIT License

