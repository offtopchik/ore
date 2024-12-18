#!/bin/bash

# ====================
# Цветовые обозначения
# ====================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета

# ============================
# Функция для обновления системы, установки зависимостей и клонирования репозитория
# ============================
update_install_and_clone() {
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}1. Обновление системы...${NC}"
  echo -e "${CYAN}==============================${NC}"
  sudo apt update && sudo apt upgrade -y || { echo -e "${RED}Ошибка обновления системы.${NC}"; exit 1; }

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}2. Установка необходимых утилит...${NC}"
  echo -e "${CYAN}==============================${NC}"
  sudo apt install -y git build-essential || { echo -e "${RED}Ошибка установки утилит.${NC}"; exit 1; }

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}3. Установка Rust...${NC}"
  echo -e "${CYAN}==============================${NC}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || { echo -e "${RED}Ошибка установки Rust.${NC}"; exit 1; }
  source "$HOME/.cargo/env"

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}4. Клонирование репозитория...${NC}"
  echo -e "${CYAN}==============================${NC}"
  if [ ! -d "ore" ]; then
    git clone https://github.com/regolith-labs/ore.git || { echo -e "${RED}Ошибка при клонировании репозитория.${NC}"; exit 1; }
  else
    echo -e "${YELLOW}Репозиторий уже клонирован.${NC}"
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}5. Установка зависимостей проекта...${NC}"
  echo -e "${CYAN}==============================${NC}"
  if [ -d "ore" ]; then
    cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
    if [ -f "Cargo.toml" ]; then
      cargo build || { echo -e "${RED}Ошибка установки зависимостей проекта.${NC}"; exit 1; }
    else
      echo -e "${RED}Файл Cargo.toml не найден. Проверьте содержимое репозитория.${NC}"
      echo -e "${YELLOW}Текущее содержимое директории:${NC}"
      ls -la
      exit 1
    fi
  else
    echo -e "${RED}Директория ore не найдена. Сначала клонируйте репозиторий.${NC}"
    exit 1
  fi
}

# ============================
# Функция для настройки окружения
# ============================
setup_environment() {
  if [ ! -d "ore" ]; then
    echo -e "${YELLOW}Директория ore не найдена. Выполняется установка ноды ORE...${NC}"
    update_install_and_clone
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Настройка файла окружения...${NC}"
  echo -e "${CYAN}==============================${NC}"
  cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
  if [ -f .env.example ]; then
    cp .env.example .env
    echo -e "${GREEN}Файл .env создан. Обновите параметры при необходимости.${NC}"
  else
    echo -e "${RED}Файл .env.example не найден.${NC}"
  fi
}

# ============================
# Функция для настройки кошелька
# ============================
setup_wallet() {
  if [ ! -d "ore" ]; then
    echo -e "${YELLOW}Директория ore не найдена. Выполняется установка ноды ORE...${NC}"
    update_install_and_clone
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Настройка кошелька...${NC}"
  echo -e "${CYAN}==============================${NC}"
  cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
  if [ -f .env ]; then
    read -rp "Введите адрес вашего кошелька: " WALLET_ADDRESS
    read -rp "Введите ваш приватный ключ: " PRIVATE_KEY
    echo "WALLET_ADDRESS=$WALLET_ADDRESS" >> .env
    echo "PRIVATE_KEY=$PRIVATE_KEY" >> .env
    echo -e "${GREEN}Кошелек успешно добавлен в файл .env.${NC}"
  else
    echo -e "${RED}Файл .env не найден. Убедитесь, что окружение настроено.${NC}"
  fi
}

# ============================
# Функция для запуска проекта
# ============================
start_project() {
  if [ ! -d "ore" ]; then
    echo -e "${YELLOW}Директория ore не найдена. Выполняется установка ноды ORE...${NC}"
    update_install_and_clone
  fi

  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Запуск проекта...${NC}"
  echo -e "${CYAN}==============================${NC}"
  cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
  cargo run || { echo -e "${RED}Ошибка запуска проекта.${NC}"; exit 1; }
}

# ============================
# Главное меню
# ============================
while true; do
  echo -e "\n${CYAN}==============================${NC}"
  echo -e "${GREEN}Выберите действие:${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo "1) Установка ноды ORE"
  echo "2) Настроить окружение"
  echo "3) Настроить кошелек"
  echo "4) Запустить проект"
  echo "5) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      update_install_and_clone
      ;;
    2)
      setup_environment
      ;;
    3)
      setup_wallet
      ;;
    4)
      start_project
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
