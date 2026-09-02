#!/bin/bash
# Module: IPv6 Management

show_ipv6_menu() {
    local sysctl_status=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)
    local interface_name=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -v lo | head -n 1)
    local ipv6_addrs=$(ip -6 addr show scope global 2>/dev/null | grep -oP 'inet6 \K[0-9a-fA-F:]+' | head -n 1)

    echo -e ""
    echo -e "${COLOR_GREEN}=================================================${COLOR_RESET}"
    echo -e "${COLOR_GREEN}               ${LANG[IPV6_MENU_TITLE]}${COLOR_RESET}"
    echo -e "${COLOR_GREEN}=================================================${COLOR_RESET}"
    
    if [ "$sysctl_status" = "0" ]; then
        echo -e " ${COLOR_WHITE}${LANG[IPV6_STATUS_LABEL]}${COLOR_RESET} ${COLOR_GREEN}● ${LANG[IPV6_STATUS_ENABLED]}${COLOR_RESET}"
    else
        echo -e " ${COLOR_WHITE}${LANG[IPV6_STATUS_LABEL]}${COLOR_RESET} ${COLOR_RED}○ ${LANG[IPV6_STATUS_DISABLED]}${COLOR_RESET}"
    fi

    if [ -n "$interface_name" ]; then
        echo -e " ${COLOR_WHITE}${LANG[IPV6_INTERFACE_LABEL]}${COLOR_RESET} ${COLOR_YELLOW}${interface_name}${COLOR_RESET}"
    fi

    if [ -n "$ipv6_addrs" ]; then
        echo -e " ${COLOR_WHITE}${LANG[IPV6_ADDRESS_LABEL]}${COLOR_RESET} ${COLOR_GREEN}${ipv6_addrs}${COLOR_RESET}"
    else
        echo -e " ${COLOR_WHITE}${LANG[IPV6_ADDRESS_LABEL]}${COLOR_RESET} ${COLOR_GRAY}${LANG[IPV6_NO_ADDRESS]}${COLOR_RESET}"
    fi
    echo -e "${COLOR_GREEN}=================================================${COLOR_RESET}"
    echo -e ""
    echo -e "${COLOR_YELLOW}1. ${LANG[IPV6_ENABLE]}${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}2. ${LANG[IPV6_DISABLE]}${COLOR_RESET}"
    echo -e ""
    echo -e "${COLOR_YELLOW}0. ${LANG[EXIT]}${COLOR_RESET}"
    echo -e ""
}

manage_ipv6() {
    show_ipv6_menu
    reading "${LANG[IPV6_PROMPT]}" IPV6_OPTION
    case $IPV6_OPTION in
        1)
            enable_ipv6
            sleep 2
            log_clear
            manage_ipv6
            ;;
        2)
            disable_ipv6
            sleep 2
            log_clear
            manage_ipv6
            ;;
        0)
            echo -e "${COLOR_YELLOW}${LANG[EXIT]}${COLOR_RESET}"
            log_clear
            remnawave_reverse
            ;;
        *)
            echo -e "${COLOR_YELLOW}${LANG[IPV6_INVALID_CHOICE]}${COLOR_RESET}"
            sleep 2
            log_clear
            manage_ipv6
            ;;
    esac
}

enable_ipv6() {
    if [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6)" -eq 0 ]; then
        echo -e "${COLOR_YELLOW}${LANG[IPV6_ALREADY_ENABLED]}${COLOR_RESET}"
        return 0
    fi

    echo -e "${COLOR_YELLOW}${LANG[ENABLE_IPV6]}${COLOR_RESET}"
    interface_name=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)

    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
    sed -i "/net.ipv6.conf.$interface_name.disable_ipv6/d" /etc/sysctl.conf

    echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.$interface_name.disable_ipv6 = 0" >> /etc/sysctl.conf

    sysctl -p > /dev/null 2>&1
    echo -e "${COLOR_GREEN}${LANG[IPV6_ENABLED]}${COLOR_RESET}"
}

disable_ipv6() {
    if [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6)" -eq 1 ]; then
        echo -e "${COLOR_YELLOW}${LANG[IPV6_ALREADY_DISABLED]}${COLOR_RESET}"
        return 0
    fi

    echo -e "${COLOR_YELLOW}${LANG[DISABLING_IPV6]}${COLOR_RESET}"
    interface_name=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)

    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
    sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
    sed -i "/net.ipv6.conf.$interface_name.disable_ipv6/d" /etc/sysctl.conf

    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf

    sysctl -p > /dev/null 2>&1
    echo -e "${COLOR_GREEN}${LANG[IPV6_DISABLED]}${COLOR_RESET}"
}
