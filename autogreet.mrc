alias autogreet.ini {
  if ($network) { return $mircdir $+ $network $+ -autogreet.ini }
  return $mircdir $+ autogreet.ini
}

on *:LOAD: {
  echo 3 -a [Autogreet] Script loaded successfully. Starting setup wizard...
  autogreet.setup
}

alias autogreet.setup {
  echo 3 -a [Autogreet] Starting setup...
  var %file = $sfile($mircdir, Select your random.txt greeting file)
  if (!%file) {
    echo 4 -a [Autogreet] Setup cancelled: No file selected.
    halt
  }
  writeini -n $autogreet.ini settings file %file
  echo 3 -a [Autogreet] File set to: %file

  var %chans = $$?="Which channels do you want to use? (e.g. #chan1 #chan2):"
  writeini -n $autogreet.ini settings channels %chans
  echo 3 -a [Autogreet] Channels set to: %chans

  writeini -n $autogreet.ini settings status on
  echo 3 -a [Autogreet] Status set to: ON

  echo 3 -a [Autogreet] Setup complete! Script is ready.
}

menu status,menubar,channel,nicklist {
  Autogreet
  .Run Setup Wizard:/autogreet.setup
  .-
  .Set autogreet on:/writeini -n $autogreet.ini settings status on | echo 3 -a [Autogreet] Enabled.
  .Set autogreet off:/writeini -n $autogreet.ini settings status off | echo 4 -a [Autogreet] Disabled.
  .-
  .Set Greetchannels:/var %c = $$?="Enter channels separated by spaces:" | writeini -n $autogreet.ini settings channels %c | echo 3 -a [Autogreet] Active channels set to: %c
  .Clear greetchannels:/remini $autogreet.ini settings channels | echo 4 -a [Autogreet] Channel filter cleared.
  .-
  .Set Greet file path:/var %f = $sfile($mircdir, Select your random.txt file) | writeini -n $autogreet.ini settings file %f | echo 3 -a [Autogreet] File path set to: %f
}

on *:JOIN:#:{
  var %status = $readini($autogreet.ini, settings, status)
  if (%status == off) { halt }
  if ($nick == $me) { halt }

  var %channels = $readini($autogreet.ini, settings, channels)
  if (%channels) && (!$istok(%channels,$chan,32)) { halt }

  var %greetfile = $readini($autogreet.ini, settings, file)
  if (!%greetfile) { var %greetfile = $mircdir\scripts\random.txt }

  if (!$isfile(%greetfile)) { halt }

  var %totalines = $lines(%greetfile)
  if (%totalines > 0) {
    var %randomline = $read(%greetfile, $r(1,%totalines))
    msg $chan $+(4[12,$nick,4]93) %randomline
  }
}

alias showgreetpath {
  var %status = $readini($autogreet.ini, settings, status)
  var %channels = $readini($autogreet.ini, settings, channels)
  var %greetfile = $readini($autogreet.ini, settings, file)
  if (!%greetfile) { var %greetfile = $mircdir\scripts\random.txt }

  echo 4 -a [Autogreet] Network: $iif($network, $network, Not connected)
  echo 4 -a [Autogreet] Config file: $autogreet.ini
  echo 4 -a [Autogreet] Status: $iif(%status, %status, on)
  echo 4 -a [Autogreet] Channels: $iif(%channels, %channels, All channels)
  echo 4 -a [Autogreet] File path: $qt(%greetfile)
  if ($isfile(%greetfile)) {
    echo 3 -a [Autogreet] File found ($lines(%greetfile) lines).
  }
  else {
    echo 4 -a [Autogreet] WARNING: File not found!
  }
}

alias greet {
  var %target = $iif($1, $1, $me)
  var %greetfile = $readini($autogreet.ini, settings, file)
  if (!%greetfile) { var %greetfile = $mircdir\scripts\random.txt }

  if (!$isfile(%greetfile)) {
    echo 4 -a [Autogreet] Error: Greeting file not found!
    halt
  }

  var %totalines = $lines(%greetfile)
  if (%totalines > 0) {
    var %randomline = $read(%greetfile, $r(1,%totalines))
    msg $chan $+(4[12,%target,4]93) %randomline
  }
}

on *:TEXT:!greet *:#:{
  greet $2
}

on *:TEXT:!greet:#:{
  greet
}
