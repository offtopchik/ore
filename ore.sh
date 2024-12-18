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

  # Установка Solana CLI
  if ! command -v solana &> /dev/null; then
    echo "Устанавливается Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
  fi

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

# Функция установки Solana CLI
install_solana_cli() {
  echo "Устанавливается Solana CLI..."
  sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
  if command -v solana &> /dev/null; then
    echo "Solana CLI успешно установлена."
  else
    echo "Ошибка при установке Solana CLI."
    exit 1
  fi
}

# Функция создания нового кошелька
create_new_wallet() {
  echo "Создаётся новый ключевой файл..."
  mkdir -p /root/.config/solana
  solana-keygen new --outfile /root/.config/solana/id.json --no-bip39-passphrase
  if [ $? -eq 0 ]; then
    echo "Ключевой файл успешно создан по пути: /root/.config/solana/id.json"
  else
    echo "Ошибка при создании ключевого файла. Убедитесь, что Solana CLI установлена."
    exit 1
  fi
}

# Функция импорта существующего кошелька
import_existing_wallet() {
  echo "Импорт существующего кошелька..."
  solana-keygen recover --outfile /root/.config/solana/id.json
  if [ $? -eq 0 ]; then
    echo "Кошелёк успешно импортирован."
  else
    echo "Ошибка при импорте кошелька. Проверьте ввод."
    exit 1
  fi
}

# Функция запуска ноды ORE
start_ore_node() {
  echo "Запуск ноды ORE..."
  if [ ! -f "/root/.config/solana/id.json" ]; then
    echo "Ошибка: Ключевой файл не найден. Сначала создайте или импортируйте кошелёк."
    return
  fi

  if [ -f "/root/.cargo/bin/ore" ]; then
    while true; do
      read -p "Введите адрес MINT (MINT_ADDRESS): " MINT_ADDRESS
      MINT_ADDRESS=$(echo "$MINT_ADDRESS" | xargs)  # Удаление лишних пробелов
      if [ -z "$MINT_ADDRESS" ]; then
        echo "Ошибка: MINT_ADDRESS не может быть пустым. Пожалуйста, введите корректный адрес."
      else
        echo "Используется адрес MINT: $MINT_ADDRESS"
        "/root/.cargo/bin/ore" stake "$MINT_ADDRESS"
        if [ $? -eq 0 ]; then
          echo "Нода успешно запущена."
          break
        else
          echo "Ошибка: Убедитесь, что адрес корректен и нода настроена. Попробуйте снова."
        fi
      fi
    done
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
  echo "2. Установка Solana CLI"
  echo "3. Создание нового кошелька"
  echo "4. Импорт существующего кошелька"
  echo "5. Запуск ноды ORE"
  echo "6. Выход"
  echo "=============================="
  read -p "Выберите действие: " choice

  case $choice in
    1)
      install_ore_node
      ;;
    2)
      install_solana_cli
      ;;
    3)
      create_new_wallet
      ;;
    4)
      import_existing_wallet
      ;;
    5)
      start_ore_node
      ;;
    6)
      echo "Выход из меню."
      exit 0
      ;;
    *)
      echo "Неверный выбор. Попробуйте снова."
      ;;
  esac
done
