#!/bin/bash

# Función para inicializar el archivo todos.md
initialize_todos() {
	if [ ! -f todos.md ]; then
		echo -e "# Todos \n" >todos.md
	fi
}

# Función para obtener la acción del usuario
get_action() {
	gum choose "Add" "Delete" "View" "Modify" "Quit"
}

# Función para agregar un nuevo todo
add_todo() {
	local todo_info
	todo_info=$(gum input --prompt "Todo info: " --placeholder "todo..." --prompt.foreground 212 --cursor.foreground 213 --width 20)
	if [ -n "$todo_info" ]; then
		echo "- $todo_info" >>todos.md
	fi
}

# Función para obtener todos los elementos que comienzan con -
get_todos() {
	local todos=()
	while IFS= read -r line; do
		if [[ "$line" == -* ]]; then
			todos+=("$(echo "$line" | sed 's/^- //')")
		fi
	done <todos.md
	gum choose "${todos[@]}"
}

# Función para eliminar un todo
delete_todo() {
	local todo_to_delete
	todo_to_delete=$(get_todos)
	if [ -n "$todo_to_delete" ]; then
		gum confirm && awk -v pattern="$todo_to_delete" '$0 !~ pattern' todos.md >temp_file && mv temp_file todos.md || echo "Todo not removed"
	fi
}

# Función para modificar un todo
modify_todo() {
	local todo_to_modify modified_todo
	todo_to_modify=$(get_todos)
	modified_todo=$(gum input --prompt "New todo: " --placeholder "new todo..." --prompt.foreground 212 --cursor.foreground 213 --width 20)
	awk -v buscar="$todo_to_modify" -v reemplazar="$modified_todo" '{sub(buscar, reemplazar)} 1' todos.md >temp_file && mv temp_file todos.md
}

# Función principal
main() {
	initialize_todos

	while :; do
		clear
		Gummy=$(gum style --padding "1 7 1 7" --border rounded --border-foreground 959 "Gummy")
		Todo=$(gum style --padding "1 7 1 7" --border rounded --border-foreground 521 "Todo")
		Penguin=$(gum style --padding "1 4" --border rounded --border-foreground 212 "
     _
   ('v')
  //-=-\\
  (\_=_/)
   ^^ ^^
    ")

		LEFT=$(gum join --vertical "$Gummy" "$Todo")
		TOP=$(gum join "$LEFT" "$Penguin")
		gum join --align center --vertical "$TOP"

		echo "What do you want to do?"
		action=$(get_action)

		case $action in
		"View")
			gum spin --spinner pulse --title "Loading" -- sleep 0.3
			gum pager <todos.md
			;;
		"Add")
			add_todo
			;;
		"Delete")
			delete_todo
			;;
		"Modify")
			modify_todo
			;;
		"Quit")
			gum spin --spinner pulse --title "Bye bye ^^" -- sleep 0.5
			exit 0
			;;
		*)
			echo "Invalid"
			;;
		esac
	done
}

main
