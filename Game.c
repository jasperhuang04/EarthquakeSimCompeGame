#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdio.h>

#define row 8
#define col 8

int x, y;

void set_random(char grid[row][col], char value, int total, char value1, int total1);
//code found from https://www.youtube.com/watch?v=rzWq24bYuvo&list=LL&index=1  lines 12-61
void set_random(char grid[row][col], char value, int total, char value1, int total1) {
    int row_ran = 0;
    int col_ran = 0;

    int prev_row[total];
    int prev_col[total];
    bool already_selected = false;
    for (int i = 0; i < total1; i++) {
        do {
            already_selected = false;
            row_ran = rand() % row;
            col_ran = rand() % col;
            if (grid[row_ran][col_ran] == 'O' || (row_ran == y && col_ran == x)) {
                already_selected = true;
            } else {
                for (int j = 0; j < i; j++) {
                    if (prev_row[j] == row_ran && prev_col[j] == col_ran) {
                        already_selected = true;
                    }
                }
            }
        } while (already_selected);
        prev_row[i] = row_ran;
        prev_col[i] = col_ran;
        grid[row_ran][col_ran] = value1;
    }

    for (int i = 0; i < total; i++) {
        do {
            already_selected = false;
            row_ran = rand() % row;
            col_ran = rand() % col;
            if (grid[row_ran][col_ran] == 'O' || (row_ran == y && col_ran == x)) {
                already_selected = true;
            } else {
                for (int j = 0; j < i; j++) {
                    if (prev_row[j] == row_ran && prev_col[j] == col_ran) {
                        already_selected = true;
                    }
                }
            }
        } while (already_selected);

        prev_row[i] = row_ran;
        prev_col[i] = col_ran;
        grid[row_ran][col_ran] = value;
    }
}

void perform_move(char board[row][col], char direction,  int *doublejump, int *count) {
    // Double jump
        if (direction == 'a') {
        x--;
        (*count)++;
    } else if (direction == 'w') {
        y--;
        (*count)++;
    } else if (direction == 's') {
        y++;
        (*count)++;
    } else if (direction == 'd') {
        x++;
        (*count)++;
    } else if (direction == 'p') {
        printf("End of game");
        exit(0);
    }
        if (*doublejump >= 1) {
            int temp_x = x;
            int temp_y = y;
            if (direction == 'A') {
                temp_x -= 2;
                (*count) += 1;
            } else if (direction == 'W') {
                temp_y -= 2;
                (*count) += 1;
            } else if (direction == 'S') {
                temp_y += 2;
                (*count) += 1;
            } else if (direction == 'D') {
                temp_x += 2;
                (*count) += 1;
            } else {
                printf("Invalid double jump. You must move to a different direction.\n");
                return;
            }
            // Check if there's an obstacle in between
            if (board[temp_y][temp_x] == 'O') {
                printf("There's an obstacle in the way. Double jump failed.\n");
                return;
            }
            // Check if the final position is valid
            if (board[temp_y][temp_x] != 'O') {
                x = temp_x;
                y = temp_y;
                (*doublejump)--;
                printf("Double jump used, you have %d left\n", *doublejump);
            } else {
                printf("You can't double jump to a position with an obstacle.\n");
                return;
            }
        } 
}

int main() {
    srand(time(NULL) * getpid());
    char board[row][col];
    int i, j;
    int doublejump = 0;
    int count = -1;
    bool gameover = false;

    printf("Place your character on a x row between 0 and 7: ");
    scanf("%d", &y);
    printf("Place your character on a y column between 0 and 7: ");
    scanf("%d", &x);

    for (i = 0; i < row; i++) {
        for (j = 0; j < col; j++) {
            board[i][j] = '.';
        }
    }

    board[y][x] = '+';

    for (i = 0; i < row; i++) {
        for (j = 0; j < col; j++) {
            printf("%c ", board[i][j]);
        }
        printf("\n");
    }

    while (!gameover) {
        printf("Next move(Use w, a, s, or d to go up, left, down, right): \n");
        char direction;
        scanf(" %c", &direction);
        board[y][x] = '.';

        perform_move(board, direction, &doublejump, &count);

        if (board[y][x] == 'O') {
            gameover = true;
            break;
        }

        if (board[y][x] == 'J') {
            printf("You unlocked a double jump, you can use it by capitalizing the direction you want to go\n");
            doublejump++;
            // DoubleJump(doublejump);
        }

        board[y][x] = '+';

        // randomly lose space
        set_random(board, 'O', 6, 'J', 1);
        for (i = 0; i < row; i++) {
            for (j = 0; j < col; j++) {
                printf("%c ", board[i][j]);
            }
            printf("\n");
        }
    }

    printf("You lose, you made it %d rounds", count);
    return 0;
}
