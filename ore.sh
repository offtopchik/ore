#!/bin/bash

# Объявляем цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Нет цвета

# Функция для обновления системы и установки зависимостей проекта
update_and_install_dependencies() {
  echo -e "${GREEN}Обновление системы и установка зависимостей...${NC}"
  sudo apt update && sudo apt upgrade -y || { echo -e "${RED}Ошибка обновления системы.${NC}"; exit 1; }

  echo -e "${GREEN}Установка Git...${NC}"
  sudo apt install -y git || { echo -e "${RED}Ошибка установки Git.${NC}"; exit 1; }

  echo -e "${GREEN}Установка компилятора C/C++...${NC}"
  sudo apt install -y build-essential || { echo -e "${RED}Ошибка установки компилятора C/C++.${NC}"; exit 1; }

  echo -e "${GREEN}Установка Rust...${NC}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || { echo -e "${RED}Ошибка установки Rust.${NC}"; exit 1; }
  source "$HOME/.cargo/env"

  echo -e "${GREEN}Установка зависимостей проекта...${NC}"
  if [ -d "ore" ]; then
    cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
    if [ -f "Cargo.toml" ]; then
      cargo build || { echo -e "${RED}Ошибка установки зависимостей проекта.${NC}"; exit 1; }
    else
      echo -e "${RED}Файл Cargo.toml не найден. Проверьте содержимое репозитория.${NC}"
      echo -e "${GREEN}Текущее содержимое директории:${NC}"
      ls -la
      exit 1
    fi
  else
    echo -e "${RED}Директория ore не найдена. Сначала клонируйте репозиторий.${NC}"
    exit 1
  fi

  echo -e "${GREEN}Система обновлена и зависимости установлены.${NC}"
}

# Функция для клонирования репозитория
clone_repository() {
  echo -e "${GREEN}Клонирование репозитория...${NC}"
  git clone https://github.com/regolith-labs/ore.git || { echo -e "${RED}Ошибка при клонировании репозитория.${NC}"; exit 1; }
  echo -e "${GREEN}Содержимое репозитория:${NC}"
  ls -la ore || { echo -e "${RED}Не удалось отобразить содержимое репозитория.${NC}"; exit 1; }
}

# Функция для настройки окружения
setup_environment() {
  echo -e "${GREEN}Настройка файла окружения...${NC}"
  if [ -d "ore" ]; then
    cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
    if [ -f .env.example ]; then
      cp .env.example .env
      echo -e "${GREEN}Файл .env создан. Обновите параметры при необходимости.${NC}"
    else
      echo -e "${RED}Файл .env.example не найден.${NC}"
    fi
  else
    echo -e "${RED}Директория ore не найдена. Сначала клонируйте репозиторий.${NC}"
  fi
}

# Функция для настройки кошелька
setup_wallet() {
  echo -e "${GREEN}Настройка кошелька...${NC}"
  if [ -d "ore" ]; then
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
  else
    echo -e "${RED}Директория ore не найдена. Сначала клонируйте репозиторий.${NC}"
  fi
}

# Функция для запуска проекта
start_project() {
  echo -e "${GREEN}Запуск проекта...${NC}"
  if [ -d "ore" ]; then
    cd ore || { echo -e "${RED}Ошибка перехода в директорию проекта.${NC}"; exit 1; }
    cargo run || { echo -e "${RED}Ошибка запуска проекта.${NC}"; exit 1; }
  else
    echo -e "${RED}Директория ore не найдена. Сначала клонируйте репозиторий.${NC}"
  fi
}

# Главное меню
while true; do
  echo -e "${GREEN}Выберите действие:${NC}"
  echo "1) Обновить систему и установить зависимости проекта"
  echo "2) Установить зависимости"
  echo "3) Клонировать репозиторий"
  echo "4) Настроить окружение"
  echo "5) Настроить кошелек"
  echo "6) Запустить проект"
  echo "7) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      update_and_install_dependencies
      ;;
    2)
      install_dependencies
      ;;
    3)
      clone_repository
      ;;
    4)
      setup_environment
      ;;
    5)
      setup_wallet
      ;;
    6)
      start_project
      ;;
    7)
      echo -e "${GREEN}Выход из программы.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      ;;
  esac
done
