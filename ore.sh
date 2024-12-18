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
GENERATED_WALLET="" # Переменная для хранения сгенерированного кошелька
PRIVATE_KEY="" # Переменная для хранения приватного ключа
NODE_PID_FILE="$HOME/ore_node.pid" # Файл для хранения PID запущенной ноды

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

  # Автоматическая генерация кошелька после установки ore-cli
  generate_wallet
}

# ==========================
# Функция для генерации кошелька
# ==========================
generate_wallet() {
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Генерация нового кошелька...${NC}"
  echo -e "${CYAN}==============================${NC}"

  WALLET_OUTPUT=$("$ORE_CLI_DIR/target/release/ore-cli" wallet generate 2>&1) || {
    echo -e "${RED}Ошибка генерации кошелька.${NC}"
    exit 1
  }

  GENERATED_WALLET=$(echo "$WALLET_OUTPUT" | grep 'Address:' | awk '{print $2}')
  PRIVATE_KEY=$(echo "$WALLET_OUTPUT" | grep 'Private Key:' | awk '{print $3}')

  echo -e "${GREEN}Кошелек успешно сгенерирован:${NC}"
  echo -e "${CYAN}Адрес: ${GENERATED_WALLET}${NC}"
  echo -e "${CYAN}Приватный ключ: ${PRIVATE_KEY}${NC}"
}

# ==========================
# Функция для показа сгенерированного кошелька
# ==========================
show_wallet() {
  if [ -z "$GENERATED_WALLET" ] || [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Кошелек еще не был сгенерирован. Сначала установите ore-cli.${NC}"
  else
    echo -e "${CYAN}Адрес кошелька: ${GENERATED_WALLET}${NC}"
    echo -e "${CYAN}Приватный ключ: ${PRIVATE_KEY}${NC}"
  fi
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
# Функция для остановки ноды
# ==========================
stop_node() {
  if [ -f "$NODE_PID_FILE" ]; then
    PID=$(cat "$NODE_PID_FILE")
    if kill -0 $PID &> /dev/null; then
      kill $PID && echo -e "${GREEN}Нода успешно остановлена.${NC}"
      rm -f "$NODE_PID_FILE"
    else
      echo -e "${RED}Нода уже не работает.${NC}"
      rm -f "$NODE_PID_FILE"
    fi
  else
    echo -e "${RED}Файл PID не найден. Нода, возможно, не запущена.${NC}"
  fi
}

# ==========================
# Главное меню
# ==========================
while true; do
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Выберите действие:${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo "1) Установка ноды ORE"
  echo "2) Показать сгенерированный кошелек"
  echo "3) Запустить ore-cli"
  echo "4) Остановить ноду"
  echo "5) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      install_ore_cli
      ;;
    2)
      show_wallet
      ;;
    3)
      start_ore_cli
      ;;
    4)
      stop_node
      ;;
    5)
      echo -e "${GREEN}Выход из программы.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      ;;
  esac
done
