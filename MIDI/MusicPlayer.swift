//
//  MusicPlayer.swift
//  MIDI
//
//  Created by Student on 3/26/15.
//
//

import AudioToolbox



func NewPlayer() -> MusicPlayer? {
    ENTRY_LOG()
    var player = MusicPlayer()
    let status = NewMusicPlayer(&player)
    
    if status != noErr {
        log.error("Failed to create new player")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return player
}

func PlayerDispose(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    let status = DisposeMusicPlayer(player)
    
    if status != noErr {
        log.error("Failed to dispose of player")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func PlayerSetSequence(player: MusicPlayer, sequence: MusicSequence) -> Bool {
    ENTRY_LOG()
    let status = MusicPlayerSetSequence(player, sequence)
    
    if status != noErr {
        log.error("Failed to set sequence")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func NewPlayerWithSequence(sequence: MusicSequence) -> MusicPlayer? {
    ENTRY_LOG()
    if let player = NewPlayer() {
        if PlayerSetSequence(player, sequence) {
            EXIT_LOG()
            return player
        }
    }
    EXIT_LOG()
    return nil
}

func PlayerIsPlaying(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    var playing = Boolean()
    let status = MusicPlayerIsPlaying(player, &playing)
    if status != noErr {
        log.error("Could not check if music player is playing")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return playing != 0
}

func PlayerGetTime(player: MusicPlayer) -> MusicTimeStamp? {
    ENTRY_LOG()
    var time = MusicTimeStamp()
    let status = MusicPlayerGetTime(player, &time)
    if status != noErr {
        log.error("Could not get player time")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return time
}

func PlayerSetTime(player: MusicPlayer, time: MusicTimeStamp) -> Bool {
    ENTRY_LOG()
    let status = MusicPlayerSetTime(player, time)
    if status != noErr {
        log.error("could not set time")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func PlayerResetTime(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    let result = PlayerSetTime(player, 0)
    EXIT_LOG()
    return result
}

func PlayerPlayFromBeginning(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    if PlayerIsPlaying(player) {
        if !PlayerStop(player) {
            EXIT_LOG()
            return false
        }
    }
    if PlayerResetTime(player) {
        EXIT_LOG()
        return PlayerStart(player)
    }
    EXIT_LOG()
    return false
}

func PlayerStart(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    let status = MusicPlayerStart(player)
    
    if status != noErr {
        log.error("Failed to start player")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func PlayerStop(player: MusicPlayer) -> Bool {
    ENTRY_LOG()
    let status = MusicPlayerStop(player)
    
    if status != noErr {
        log.error("Failed to stop player")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}


// TODO add function for reseting, etc..