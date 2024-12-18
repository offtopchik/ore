#!/bin/bash

# Объявляем цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Нет цвета

# Функция для обновления системы
update_system() {
  echo -e "${GREEN}Обновление системы...${NC}"
  sudo apt update && sudo apt upgrade -y || { echo -e "${RED}Ошибка обновления системы.${NC}"; exit 1; }
  echo -e "${GREEN}Система успешно обновлена.${NC}"
}

# Функция для установки утилит
install_dependencies() {
  echo -e "${GREEN}Обновление списка пакетов...${NC}"
  sudo apt update || { echo -e "${RED}Ошибка обновления списка пакетов.${NC}"; exit 1; }

  echo -e "${GREEN}Установка Git...${NC}"
  sudo apt install -y git || { echo -e "${RED}Ошибка установки Git.${NC}"; exit 1; }

  echo -e "${GREEN}Установка Node.js...${NC}"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || { echo -e "${RED}Ошибка настройки репозитория Node.js.${NC}"; exit 1; }
  sudo apt install -y nodejs || { echo -e "${RED}Ошибка установки Node.js.${NC}"; exit 1; }

  echo -e "${GREEN}Установка curl...${NC}"
  sudo apt install -y curl || { echo -e "${RED}Ошибка установки curl.${NC}"; exit 1; }

  echo -e "${GREEN}Все зависимости установлены.${NC}"
}

# Функция для клонирования репозитория
clone_repository() {
  echo -e "${GREEN}Клонирование репозитория...${NC}"
  git clone https://github.com/regolith-labs/ore.git || { echo -e "${RED}Ошибка при клонировании репозитория.${NC}"; exit 1; }
  cd ore || { echo -e "${RED}Ошибка перехода в директорию репозитория.${NC}"; exit 1; }
}

# Функция для установки зависимостей проекта
install_project_dependencies() {
  echo -e "${GREEN}Установка зависимостей проекта...${NC}"
  npm install || { echo -e "${RED}Ошибка установки зависимостей проекта.${NC}"; exit 1; }
}

# Функция для настройки окружения
setup_environment() {
  echo -e "${GREEN}Настройка файла окружения...${NC}"
  if [ -f .env.example ]; then
    cp .env.example .env
    echo -e "${GREEN}Файл .env создан. Обновите параметры при необходимости.${NC}"
  else
    echo -e "${RED}Файл .env.example не найден.${NC}"
  fi
}

# Функция для настройки кошелька
setup_wallet() {
  echo -e "${GREEN}Настройка кошелька...${NC}"
  read -rp "Введите адрес вашего кошелька: " WALLET_ADDRESS
  read -rp "Введите ваш приватный ключ: " PRIVATE_KEY

  if [ -f .env ]; then
    echo "WALLET_ADDRESS=$WALLET_ADDRESS" >> .env
    echo "PRIVATE_KEY=$PRIVATE_KEY" >> .env
    echo -e "${GREEN}Кошелек успешно добавлен в файл .env.${NC}"
  else
    echo -e "${RED}Файл .env не найден. Убедитесь, что окружение настроено.${NC}"
  fi
}

# Функция для запуска проекта
start_project() {
  echo -e "${GREEN}Запуск проекта...${NC}"
  npm start || { echo -e "${RED}Ошибка запуска проекта.${NC}"; exit 1; }
}

# Главное меню
while true; do
  echo -e "${GREEN}Выберите действие:${NC}"
  echo "1) Обновить систему"
  echo "2) Установить зависимости"
  echo "3) Клонировать репозиторий"
  echo "4) Установить зависимости проекта"
  echo "5) Настроить окружение"
  echo "6) Настроить кошелек"
  echo "7) Запустить проект"
  echo "8) Выход"

  read -rp "Введите номер действия: " choice

  case $choice in
    1)
      update_system
      ;;
    2)
      install_dependencies
      ;;
    3)
      clone_repository
      ;;
    4)
      install_project_dependencies
      ;;
    5)
      setup_environment
      ;;
    6)
      setup_wallet
      ;;
    7)
      start_project
      ;;
    8)
      echo -e "${GREEN}Выход из программы.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      ;;
  esac
done
