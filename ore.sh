#!/bin/bash

# Проверка выполнения команд и завершение скрипта при ошибке
set -e

# Функция полной установки ноды ORE
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

  # Убедиться, что Cargo bin в PATH
  export PATH="$HOME/.cargo/bin:$PATH"

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
  /root/.cargo/bin/ore --version || echo "Ошибка: Убедитесь, что ore-cli установлен правильно."

  echo "Установка и настройка ORE завершены!"
}

# Функция запуска ноды ORE
start_ore_node() {
  echo "Запуск ноды ORE..."
  if [ -f "/root/.cargo/bin/ore" ]; then
    "/root/.cargo/bin/ore" stake || echo "Ошибка: Убедитесь, что нода настроена корректно."
  else
    echo "Ошибка: Команда ore не найдена. Проверьте установку."
  fi
}

# Меню выбора действий
while true; do
  echo "=============================="
  echo " Меню установки и управления ORE"
  echo "=============================="
  echo "1. Полная установка ноды ORE"
  echo "2. Запуск ноды ORE"
  echo "3. Выход"
  echo "=============================="
  read -p "Выберите действие: " choice

  case $choice in
    1)
      install_ore_node
      ;;
    2)
      start_ore_node
      ;;
    3)
      echo "Выход из меню."
      exit 0
      ;;
    *)
      echo "Неверный выбор. Попробуйте снова."
      ;;
  esac
done

