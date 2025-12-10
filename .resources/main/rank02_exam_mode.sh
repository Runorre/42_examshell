#!/bin/bash
source colors.sh

rank=$1
level=$2

# Save base directory (where script was launched from)
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Centralized temp file to track subject
subject_file="/tmp/.current_subject_${rank}_${level}"

# Define subject pool using case statement instead of associative array
get_subjects() {
    case "$level" in
        level0)
            echo "first_word fizzbuzz ft_putstr ft_strcpy ft_strlen ft_swap repeat_alpha rev_print rot_13 rotone search_and_replace ulstr"
            ;;
        level1)
            echo "ft_atoi ft_strcmp ft_strrev ft_strdup inter last_word union wdmatch"
            ;;
        level2)
            echo "ft_list_size ft_atoi_base ft_range ft_rrange"
            ;;
        level3)
            echo "ft_itoa ft_split ft_list_foreach sort_list ft_list_remove_if"
            ;;
        *)
            echo ""
            ;;
    esac
}

pick_new_subject() {
    subjects_list=$(get_subjects)
    IFS=' ' read -r -a qsub <<< "$subjects_list"
    count=${#qsub[@]}
    random_index=$(( RANDOM % count ))
    chosen="${qsub[$random_index]}"
    echo "$chosen" > "$subject_file"
}

prepare_subject() {
    mkdir -p "$base_dir/../../rendu/$chosen"
    touch "$base_dir/../../rendu/$chosen/$chosen.c"

    cd "$base_dir/../$rank/$level/$chosen" || {
        echo -e "${RED}Subject folder not found.${RESET}"
        exit 1
    }

    clear
    echo -e "${CYAN}${BOLD}Your subject: $chosen${RESET}"
    echo "=================================================="
    cat sub.txt
    echo
    echo -e "=================================================="
    echo -e "${YELLOW}Type 'test' to test your code, 'next' to get a new question, or 'exit' to quit.${RESET}"
}

# Initial subject selection
if [ -f "$subject_file" ]; then
    chosen=$(cat "$subject_file")
    echo -e "${BLUE}🔁 Resuming with previously chosen subject: $chosen${RESET}"
else
    pick_new_subject
fi

prepare_subject

# Command loop
while true; do
    read -rp "/> " input
    case "$input" in
        test)
            clear
            echo -e "${GREEN}Running tester.sh...${RESET}"
            output=$(./tester.sh 2>&1)
            echo "$output" | tee tester_output.log

            if echo "$output" | grep -q -E "PASSED|SUCCESS"; then
                echo -e "${GREEN}${BOLD}✔️  Passed!${RESET}"
                rm -f "$subject_file"
                sleep 1
                exit 0
            else
                echo -e "${RED}${BOLD}❌  Failed.${RESET}"
                sleep 1
                exit 1
            fi
            ;;
        next)
            echo -e "${BLUE}🔄 Picking a new subject...${RESET}"
            pick_new_subject
            chosen=$(cat "$subject_file")
            prepare_subject
            ;;
        exit)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Please type 'test' to test code, 'next' for next or 'exit' for exit."
            ;;
    esac
done
