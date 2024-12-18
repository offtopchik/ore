#!/bin/bash

# Скрипт для установки зависимостей и Solana CLI

set -e  # Завершить выполнение при ошибке

# Цвета для вывода
GREEN='\033[0;32m'
NC='\033[0m'

# Функция для вывода сообщения об успешной установке
function success_message() {
    echo -e "${GREEN}$1${NC}"
}

# Обновление пакетов и установка curl, git
success_message "Обновляем пакеты и устанавливаем curl и git..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential pkg-config libssl-dev

# Установка Rust (если не установлен)
success_message "Проверяем установку Rust..."
if ! command -v rustc &> /dev/null; then
    success_message "Устанавливаем Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    success_message "Rust уже установлен. Пропускаем."
fi

# Установка Node.js (LTS)
success_message "Устанавливаем Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
else
    success_message "Node.js уже установлен. Пропускаем."
fi

# Установка npm пакетов (yarn)
success_message "Устанавливаем Yarn..."
if ! command -v yarn &> /dev/null; then
    npm install --global yarn
else
    success_message "Yarn уже установлен. Пропускаем."
fi

# Установка Solana CLI
success_message "Устанавливаем Solana CLI..."
success_message "Получаем последнюю версию Solana CLI..."
LATEST_SOLANA_VERSION=$(curl -sSfL https://release.anza.xyz/stable/version)
if [ -z "$LATEST_SOLANA_VERSION" ]; then
    echo "Ошибка: не удалось получить последнюю версию Solana CLI. Проверьте соединение или URL."
    exit 1
fi

success_message "Устанавливаем версию $LATEST_SOLANA_VERSION..."
sh -c "$(curl -sSfL https://release.anza.xyz/$LATEST_SOLANA_VERSION/install)"

# Проверка Solana CLI
if command -v solana &> /dev/null; then
    success_message "Solana CLI успешно установлена!"
    solana --version
else
    echo "Ошибка: Solana CLI не установлена. Проверьте ошибки."
    exit 1
fi

# Настройка RPC (mainnet-beta)
success_message "Настраиваем RPC для mainnet-beta..."
solana config set --url https://api.mainnet-beta.solana.com

# Показать текущую конфигурацию
success_message "Конфигурация Solana CLI:"
solana config get

success_message "Установка завершена!"
