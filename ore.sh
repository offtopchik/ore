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
NODE_PID_FILE="$HOME/ore_node.pid" # Файл для хранения PID запущенной ноды
ORE_EXECUTABLE="" # Переменная для хранения пути к исполняемому файлу
KEYPAIR_PATH="$HOME/.config/solana/id.json" # Путь к ключевому файлу

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

  sudo apt install -y git build-essential curl pkg-config libssl-dev solana-cli || {
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
# Проверка наличия ключевого файла
# ==========================
check_keypair() {
  if [ ! -f "$KEYPAIR_PATH" ]; then
    echo -e "${YELLOW}Ключевой файл не найден. Создание нового ключа...${NC}"
    mkdir -p "$(dirname "$KEYPAIR_PATH")"
    solana-keygen new --outfile "$KEYPAIR_PATH" || {
      echo -e "${RED}Ошибка создания ключевого файла.${NC}"
      exit 1
    }
    echo -e "${GREEN}Ключ успешно создан и сохранен по пути: $KEYPAIR_PATH${NC}"
  else
    echo -e "${GREEN}Ключевой файл найден: $KEYPAIR_PATH${NC}"
  fi
}

# ==========================
# Поиск исполняемого файла ore-cli
# ==========================
find_executable() {
  if [ -x "$ORE_CLI_DIR/target/release/ore" ]; then
    ORE_EXECUTABLE="$ORE_CLI_DIR/target/release/ore"
  elif [ -x "$ORE_CLI_DIR/target/release/ore-cli" ]; then
    ORE_EXECUTABLE="$ORE_CLI_DIR/target/release/ore-cli"
  else
    echo -e "${RED}Исполняемый файл ore или ore-cli не найден. Попробуйте собрать проект снова: cargo build --release.${NC}"
    exit 1
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

  find_executable
  echo -e "${GREEN}ore-cli успешно установлен.${NC}"
}

# ==========================
# Функция для запуска ore-cli
# ==========================
start_ore_cli() {
  find_executable
  check_keypair

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Выберите команду для выполнения:${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo "1) balance - Узнать баланс"
  echo "2) benchmark - Тест производительности"
  echo "3) mine - Начать майнинг"
  echo "4) rewards - Посмотреть награды"
  echo "5) transfer - Отправить ORE"
  echo "6) custom - Ввести свою команду"

  read -rp "Введите номер команды: " command_choice

  case $command_choice in
    1)
      ore_command="balance"
      ;;
    2)
      ore_command="benchmark"
      ;;
    3)
      ore_command="mine --keypair $KEYPAIR_PATH"
      ;;
    4)
      ore_command="rewards"
      ;;
    5)
      read -rp "Введите сумму для отправки: " amount
      read -rp "Введите адрес получателя: " recipient
      ore_command="transfer $amount $recipient --keypair $KEYPAIR_PATH"
      ;;
    6)
      read -rp "Введите свою команду: " ore_command
      ;;
    *)
      echo -e "${RED}Неверный выбор. Возврат в меню.${NC}"
      return
      ;;
  esac

  "$ORE_EXECUTABLE" $ore_command || {
    echo -e "${RED}Ошибка выполнения команды: $ore_command${NC}"
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
  echo "2) Запустить ore-cli"
  echo "3) Остановить ноду"
  echo "4) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      install_ore_cli
      ;;
    2)
      start_ore_cli
      ;;
    3)
      stop_node
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
