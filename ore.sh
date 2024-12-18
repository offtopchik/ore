#!/bin/bash

# ====================
# Цветовые обозначения
# ====================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета

# ====================
# Глобальные переменные
# ====================
ORE_CLI_DIR="$HOME/ore-cli"   # Укажите полный путь к ore-cli

# ==========================
# Проверка и установка обновлений и зависимостей
# ==========================
update_and_install_dependencies() {
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Обновление системы и установка необходимых программ...${NC}"
  echo -e "${CYAN}==============================${NC}"

  sudo apt update && sudo apt upgrade -y || {
    echo -e "${RED}Ошибка обновления системы.${NC}"
    exit 1
  }

  sudo apt install -y git build-essential curl pkg-config libssl-dev || {
    echo -e "${RED}Ошибка установки необходимых пакетов.${NC}"
    exit 1
  }

  echo -e "${GREEN}Система обновлена и зависимости установлены.${NC}"
}

# ==========================
# Проверка и установка Rust
# ==========================
check_and_install_rust() {
  if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}Rust не установлен. Выполняется установка...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || {
      echo -e "${RED}Ошибка установки Rust.${NC}"
      exit 1
    }
    source "$HOME/.cargo/env"
  else
    echo -e "${GREEN}Rust уже установлен.${NC}"
  fi
}

# ==========================
# Функция для установки ore-cli
# ==========================
install_ore_cli() {
  update_and_install_dependencies
  check_and_install_rust

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Установка ore-cli...${NC}"
  echo -e "${CYAN}==============================${NC}"

  if [ ! -d "$ORE_CLI_DIR" ]; then
    git clone https://github.com/regolith-labs/ore-cli.git "$ORE_CLI_DIR" || {
      echo -e "${RED}Ошибка клонирования ore-cli.${NC}"
      exit 1
    }
  else
    echo -e "${YELLOW}ore-cli уже клонирован.${NC}"
  fi

  cd "$ORE_CLI_DIR" || {
    echo -e "${RED}Ошибка перехода в директорию ore-cli.${NC}"
    exit 1
  }

  cargo build --release || {
    echo -e "${RED}Ошибка сборки ore-cli.${NC}"
    exit 1
  }

  echo -e "${GREEN}ore-cli успешно установлен.${NC}"
}

# ==========================
# Функция для настройки кошелька с помощью ore-cli
# ==========================
setup_wallet() {
  if [ ! -d "$ORE_CLI_DIR" ]; then
    echo -e "${YELLOW}ore-cli не найден. Выполняется установка...${NC}"
    install_ore_cli
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Настройка кошелька...${NC}"
  echo -e "${CYAN}==============================${NC}"

  read -rp "Введите адрес вашего кошелька: " WALLET_ADDRESS
  read -rp "Введите ваш приватный ключ: " PRIVATE_KEY

  "$ORE_CLI_DIR/target/release/ore-cli" wallet add \
    --address "$WALLET_ADDRESS" \
    --private-key "$PRIVATE_KEY" || {
    echo -e "${RED}Ошибка добавления кошелька.${NC}"
    exit 1
  }

  echo -e "${GREEN}Кошелек успешно добавлен.${NC}"
}

# ==========================
# Функция для запуска ore-cli
# ==========================
start_ore_cli() {
  if [ ! -d "$ORE_CLI_DIR" ]; then
    echo -e "${YELLOW}ore-cli не найден. Выполняется установка...${NC}"
    install_ore_cli
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Запуск ore-cli...${NC}"
  echo -e "${CYAN}==============================${NC}"

  "$ORE_CLI_DIR/target/release/ore-cli" || {
    echo -e "${RED}Ошибка запуска ore-cli.${NC}"
    exit 1
  }
}

# ==========================
# Главное меню
# ==========================
while true; do
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Выберите действие:${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo "1) Установить ore-cli"
  echo "2) Настроить кошелек"
  echo "3) Запустить ore-cli"
  echo "4) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      install_ore_cli
      ;;
    2)
      setup_wallet
      ;;
    3)
      start_ore_cli
      ;;
    4)
      echo -e "${GREEN}Выход из программы.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      ;;
  esac
done

