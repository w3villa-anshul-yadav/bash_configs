alias jumps='ssh dev@13.41.61.45'
alias dev1="ssh ubuntu@3.9.155.61"
alias dev2="ssh ubuntu@52.56.38.183"
alias dev3="ssh ubuntu@13.42.132.223"
alias dev4="ssh ubuntu@13.41.124.236"

alias deploy1='pm2 deploy ecosystem.config.js quick-dev1 --force'
alias deploy2='pm2 deploy ecosystem.config.js quick-dev2 --force'
alias deploy3='pm2 deploy ecosystem.config.js quick-dev3 --force'
alias deploy4='pm2 deploy ecosystem.config.js quick-dev4 --force'


# we_want_more
alias nes='npm run start:dev'
alias wwms='ssh -L 3307:localhost:3306 ubuntu@44.219.152.181'
alias deployws='pm2 deploy ecosystem.config.js staging --force'

alias wwmp='ssh -L 3308:localhost:3306 ubuntu@54.237.123.182'

alias tims='ssh -L 3309:localhost:3306 w3villa@calendar.kivo.ai'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
