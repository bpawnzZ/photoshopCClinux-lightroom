#!/usr/bin/env bash

source "sharedFuncs.sh"

main() {    

    CMD_PATH="/usr/local/bin/photoshop"
    ENTRY_PATH="/home/$USER/.local/share/applications/photoshop.desktop"
    
    notify-send "Photoshop CC" "photoshop uninstaller started" -i "photoshop"

    ask_question "you are uninstalling photoshop cc v19 are you sure?" "N"
    if [ "$question_result" == "no" ];then
        show_message "Ok good Bye :)"
        exit 0
    fi
    
    #remove photoshop directory
    if [ -d "$SCR_PATH" ];then
        show_message "remove photoshop directory..."
        rm -r "$SCR_PATH" || error "couldn't remove photoshop directory"
        sleep 4
    else
        warning "photoshop directory Not Found!"
    fi
    
    
    #Unlink command
    if [ -L "$CMD_PATH" ];then
        show_message "remove launcher command..."
        sudo unlink "$CMD_PATH" || error "couldn't remove launcher command"
    else
        warning "launcher command Not Found!"
    fi

    #delete desktop entry
    if [ -f "$ENTRY_PATH" ];then
        show_message "remove desktop entry...."
        rm "$ENTRY_PATH" || error "couldn't remove desktop entry"
    else
        warning "desktop entry Not Found!"
    fi

    #delete cache directoy
    if [ -d "$CACHE_PATH" ];then
        show_message "--------------------------------"
        show_message "all downloaded components are in cache directory and you can use them for photoshop installation next time without wasting internet traffic"
        show_message "your cache directory is \033[1;36m$CACHE_PATH\e[0m"
        show_message "--------------------------------"
        ask_question "would you delete cache directory?" "N"
        if [ "$question_result" == "yes" ];then
            rm -rf "$CACHE_PATH" || error "couldn't remove cache directory"
            show_message "cache directory removed."
        else
            show_message "nice, you can use downloaded data later for photoshop installation"
        fi
    else
        warning "cache directory Not Found!"
    fi

}



load_paths
main
