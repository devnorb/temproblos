#!/bin/bash

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version DOWNGRADE"

    echo -ne "Checking License..."
    curl -s "https://git.abyssdigital.xyz/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    
    curl -s "https://git.abyssdigital.xyz/sellix/hwid" -o "./hwid"
    chmod +x ./hwid
    
    local user_hwid=$(./hwid)
    local hwid_resp=$(curl -s "https://git.abyssdigital.xyz/api/whitelist?hwid=$user_hwid" | ./jq -r ".success")
    rm ./hwid
    
    if [ "$hwid_resp" != "true" ]
    then
        echo -ne "\rEnter License Key:       \b\b\b\b\b\b"
        read input_key

        echo -n "Contacting Secure Api... "
        
        local resp=$(curl -s "https://git.abyssdigital.xyz/api/sellix?key=$input_key&hwid=$user_hwid")
        echo -e "Done.\n$resp"
        
        if [ "$resp" != 'Key Activation Complete!' ]
        then
            rm ./jq
            exit
            return
        fi
    else
        echo -e " Done.\nWhitelist Status Verified."
    fi

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    # https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer
    curl "http://setup.rbxcdn.com/mac/version-a142ab18cef44feb-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    rm ./jq

    echo -n "Installing Latest Roblox... "
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    curl "https://git.abyssdigital.xyz/main/macsploit.zip" -o "./MacSploit.zip"

    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip"
    echo -e "Done."

    echo -n "Updating Dylib..."
    curl -Os "https://git.abyssdigital.xyz/preview/macsploit.dylib"
    curl -Os "https://raw.githubusercontent.com/devnorb/temproblos/main/libNoUpdate.dylib"

    echo -e " Done."
    echo -e "Patching Roblox..."
    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    mv ./libNoUpdate.dylib "/Applications/Roblox.app/Contents/MacOS/libUpdateDisabler.dylib"
    mv ./libdiscord-rpc.dylib "/Applications/Roblox.app/Contents/MacOS/libdiscord-rpc.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    echo -e " !!! PRESS n !!! "
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/libUpdateDisabler.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig 
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    echo -n "Installing MacSploit App... "
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./MacSploit.zip
    echo -e "Done."

    echo -e "Install Complete! Developed by Nexus42 (norb was here)!"
    exit
}

main
