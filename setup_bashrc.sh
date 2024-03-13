#!/bin/bash


echo "" >> ~/.bashrc
echo "if [ -f ~/dotfiles-public/shell/bashrc ]; then" >> ~/.bashrc
echo " 	. ~/dotfiles-public/shell/bashrc" >> ~/.bashrc
echo "fi" >> ~/.bashrc

echo "The next shell you start will be set up with our bashrc setup"
echo "If you want to have it in this shell, run"
echo ""
echo "   . ~/.bashrc"
echo
