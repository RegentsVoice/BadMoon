# BadMoon.sh

<img width="1262" height="944" alt="изображение" src="https://github.com/user-attachments/assets/6b297718-5ceb-4ddf-9990-ba19a2b5e3b6" />

[English](#English) | [Русский](#Русский)



## English

### Project Description 📜

BadMoon.sh is a Bash script for fetching and displaying images from Konachan and Yandere websites. It provides a terminal-based interface to browse images, download them, view links and tags, toggle NSFW filters, and select between supported sites.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/BadMoon.git
   cd BadMoon
   ```
2. Make the script executable:
   ```bash
   chmod +x BadMoon.sh
   ```

### Usage

Run the script in a Bash terminal:
```bash
./BadMoon.sh
```

**Main Menu Options**:
- **Show Image**: Fetch and display a random image (or based on tags).
- **Download**: Save the current image to `~/Pictures/BadMoon/`.
- **Show Link**: Display the URL of the current image's post.
- **Show Tags**: Show tags associated with the current image.
- **Settings** ⚙️:
  - Toggle NSFW: Enable or disable NSFW content.
  - Select Site: Choose between Konachan and Yandere.
  - Back: Return to the main menu.
- **Enter Tags**: Input custom tags for image search (space-separated, empty for random).
- **Exit**: Close the script.

**Navigation**:
- Use ↑/↓ arrow keys to navigate menus.
- Press Enter to select an option.

### Dependencies

The script requires the following tools:
- `bash`: For running the script.
- `curl`: For making API requests.
- `jq`: For parsing JSON responses.
- `kitty`: For displaying images in the terminal (requires `icat` support).

Install dependencies on Ubuntu/Debian:
```bash
sudo apt update && sudo apt install curl jq kitty
```

Install dependencies on Arch/Arch based:
```bash
sudo pacman -Syu && sudo pacman -S curl jq kitty
```

Or on Fedora:
```bash
sudo dnf install curl jq kitty
```

### Troubleshooting 🛠️

- **Script exits immediately**:
  - Ensure you're running the script in `bash`:
    ```bash
    bash ./BadMoon.sh
    ```
  - Check if all dependencies are installed:
    ```bash
    command -v curl jq kitty
    ```
- **No images display**:
  - Verify `kitty` supports `icat`:
    ```bash
    kitty +kitten icat --version
    ```
  - Try running in a different terminal (e.g., `xterm`, `gnome-terminal`).
- **API errors**:
  - Check your internet connection.
  - Ensure tags are valid for the selected site.

---

## Русский

### Описание проекта 📜

BadMoon.sh — это Bash-скрипт для загрузки и отображения изображений с сайтов Konachan и Yandere. Он предоставляет интерфейс в терминале для просмотра изображений, их скачивания, отображения ссылок и тегов, переключения фильтра NSFW и выбора сайта.

### Установка

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/yourusername/BadMoon.git
   cd BadMoon
   ```
2. Сделайте скрипт исполняемым:
   ```bash
   chmod +x BadMoon.sh
   ```

### Использование

Запустите скрипт в терминале Bash:
```bash
./BadMoon.sh
```

**Опции главного меню**:
- **Show Image**: Загрузить и показать случайное изображение (или по тегам).
- **Download**: Сохранить текущее изображение в `~/Pictures/BadMoon/`.
- **Show Link**: Показать URL поста с текущим изображением.
- **Show Tags**: Показать теги, связанные с текущим изображением.
- **Settings** ⚙️:
  - Toggle NSFW: Включить или выключить NSFW-контент.
  - Select Site: Выбрать между Konachan и Yandere.
  - Back: Вернуться в главное меню.
- **Enter Tags**: Ввести пользовательские теги для поиска (через пробел, пусто — случайный выбор).
- **Exit**: Закрыть скрипт.

**Навигация**:
- Используйте клавиши ↑/↓ для перемещения по меню.
- Нажмите Enter для выбора опции.

### Зависимости

Для работы скрипта нужны следующие утилиты:
- `bash`: Для запуска скрипта.
- `curl`: Для выполнения API-запросов.
- `jq`: Для обработки JSON-ответов.
- `kitty`: Для отображения изображений в терминале (требуется поддержка `icat`).

Установка зависимостей на Ubuntu/Debian:
```bash
sudo apt update && sudo apt install curl jq kitty
```

Установка зависимостей на Arch/Arch based:
```bash
sudo pacman -Syu && sudo pacman -S curl jq kitty
```

Или на Fedora:
```bash
sudo dnf install curl jq kitty
```

### Устранение неполадок 🛠️

- **Скрипт сразу завершается**:
  - Убедитесь, что запускаете скрипт в `bash`:
    ```bash
    bash ./BadMoon.sh
    ```
  - Проверьте наличие всех зависимостей:
    ```bash
    command -v curl jq kitty
    ```
- **Изображения не отображаются**:
  - Убедитесь, что `kitty` поддерживает `icat`:
    ```bash
    kitty +kitten icat --version
    ```
  - Попробуйте другой терминал (например, `xterm`, `gnome-terminal`).
- **Ошибки API**:
  - Проверьте подключение к интернету.
  - Убедитесь, что теги подходят для выбранного сайта.
