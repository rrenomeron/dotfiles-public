#!/bin/bash


echo "" >> ~/.bashrc
echo "if [ -f ~/dotfiles/shell/bashrc ]; then" >> ~/.bashrc
echo " 	. ~/dotfiles/shell/bashrc" >> ~/.bashrc
echo "fi" >> ~/.bashrc

echo "The next shell you start will be set up with our bashrc setup"
echo "If you want to have it in this shell, run"
echo ""
echo "   . ~/.bashrc"
echo
