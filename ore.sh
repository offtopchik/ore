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
ORE_NODE_DIR="$HOME/ore-node" # Укажите полный путь к ore-node
ORE_CLI_DIR="$HOME/ore-cli"   # Укажите полный путь к ore-cli

# ==========================
# Функция для установки ноды ORE
# ==========================
install_ore_node() {
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}1. Установка ноды ORE...${NC}"
  echo -e "${CYAN}==============================${NC}"

  sudo apt update && sudo apt upgrade -y && sudo apt install -y git build-essential curl || {
    echo -e "${RED}Ошибка установки зависимостей.${NC}"
    exit 1
  }

  if [ ! -d "$ORE_NODE_DIR" ]; then
    git clone https://github.com/regolith-labs/ore.git "$ORE_NODE_DIR" || {
      echo -e "${RED}Ошибка клонирования репозитория ноды.${NC}"
      exit 1
    }
  else
    echo -e "${YELLOW}Репозиторий ноды уже клонирован.${NC}"
  fi

  cd "$ORE_NODE_DIR" || {
    echo -e "${RED}Ошибка перехода в директорию ноды.${NC}"
    exit 1
  }

  cargo build --release || {
    echo -e "${RED}Ошибка сборки ноды.${NC}"
    exit 1
  }

  echo -e "${GREEN}Нода ORE успешно установлена.${NC}"
}

# ==========================
# Функция для запуска ноды ORE
# ==========================
start_ore_node() {
  if [ ! -d "$ORE_NODE_DIR" ]; then
    echo -e "${YELLOW}Нода ORE не найдена. Выполняется установка...${NC}"
    install_ore_node
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Запуск ноды ORE...${NC}"
  echo -e "${CYAN}==============================${NC}"

  cd "$ORE_NODE_DIR" || {
    echo -e "${RED}Ошибка перехода в директорию ноды.${NC}"
    exit 1
  }

  cargo run --release || {
    echo -e "${RED}Ошибка запуска ноды.${NC}"
    exit 1
  }
}

# ==========================
# Функция для установки ore-cli
# ==========================
install_ore_cli() {
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}1. Установка ore-cli...${NC}"
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
  echo "1) Установить ноду ORE"
  echo "2) Запустить ноду ORE"
  echo "3) Установить ore-cli"
  echo "4) Настроить кошелек"
  echo "5) Запустить ore-cli"
  echo "6) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      install_ore_node
      ;;
    2)
      start_ore_node
      ;;
    3)
      install_ore_cli
      ;;
    4)
      setup_wallet
      ;;
    5)
      start_ore_cli
      ;;
    6)
      echo -e "${GREEN}Выход из программы.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      ;;
  esac
done
