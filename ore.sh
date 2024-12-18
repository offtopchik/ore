#!/bin/bash

# Проверка выполнения команд и завершение скрипта при ошибке
set -e

# Установка ноды ORE
install_ore_node() {
  echo "Начинается установка ноды ORE..."

  # Обновление системы
  sudo apt update && sudo apt upgrade -y

  # Установка необходимых пакетов
  sudo apt install -y openssl pkg-config libssl-dev build-essential curl git

  # Установка Rust и Cargo
  if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi

  # Обновление переменной PATH для текущей сессии
  if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi

  # Клонирование репозитория и установка через Cargo
  if [ ! -d "ore-cli" ]; then
    git clone https://github.com/regolith-labs/ore-cli.git
  fi

  cd ore-cli

  # Установка через Cargo
  cargo install --path .

  # Убедиться, что бинарный файл доступен
  if [ ! -f "/usr/local/bin/ore" ]; then
    sudo ln -s $(pwd)/bin/ore /usr/local/bin/ore
  fi

  # Проверка установки
  ore --version || echo "Ошибка: Убедитесь, что ore-cli установлен правильно."

  echo "Установка и настройка ORE завершены!"

  # Автоматический запуск ноды
  echo "Запуск ноды ORE..."
  ore start || echo "Ошибка: Убедитесь, что нода настроена корректно."
}

# Автоматическая установка и запуск
install_ore_node
