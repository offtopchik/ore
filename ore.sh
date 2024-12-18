#!/bin/bash

# Проверка выполнения команд и завершение скрипта при ошибке
set -e

# Функция установки ноды ORE
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

  # Клонирование репозитория
  if [ ! -d "ore-cli" ]; then
    git clone https://github.com/regolith-labs/ore-cli.git
  fi

  cd ore-cli

  # Обновление репозитория
  git pull origin main

  # Установка зависимостей через Cargo
  cargo install --path .

  # Убедиться, что бинарный файл доступен
  if [ ! -f "/usr/local/bin/ore" ]; then
    sudo ln -s $(pwd)/bin/ore /usr/local/bin/ore
  fi

  # Проверка установки
  ore --version || echo "Ошибка: Убедитесь, что ore-cli установлен правильно."

  # Обновление данных (пример)
  ore update || echo "Ошибка при обновлении данных."

  echo "Установка и настройка ORE завершены!"
}

# Функция запуска ноды
run_ore_node() {
  echo "Запуск ноды ORE..."
  ore start || echo "Ошибка: Убедитесь, что нода настроена корректно."
}

# Меню выбора действий
while true; do
  echo "=============================="
  echo " Меню установки и управления ORE"
  echo "=============================="
  echo "1. Установка ноды ORE"
  echo "2. Запустить ноду ORE"
  echo "3. Выход"
  echo "=============================="
  read -p "Выберите действие: " choice

  case $choice in
    1)
      install_ore_node
      ;;
    2)
      run_ore_node
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
