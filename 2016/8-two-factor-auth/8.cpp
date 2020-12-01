#include <cstring>
#include <iostream>

#define SCREEN_WIDTH 50
#define SCREEN_HEIGHT 6

using namespace std;

class CombiScreen {
	public:
		CombiScreen() {
		}

		void print() {
			int i, j;
			for (i = 0; i < SCREEN_HEIGHT; i++) {
				for (j = 0; j < SCREEN_WIDTH; j++) {
					cout << (_data[i][j] ? '#' : '.');
				}
				cout << endl;
			}
		}

		int sum() {
			int sum = 0;
			for (int el = 0; el < SCREEN_HEIGHT * SCREEN_WIDTH; el++) {
				sum += *(*_data + el);
			}
			return sum;
		}

		void rect(int x, int y) {
			for (int i = 0; i < y; i++) {
				for (int j = 0; j < x; j++) {
					_data[i][j] = 1;
				}
			}
			for (int i = SCREEN_HEIGHT; i < SCREEN_HEIGHT + y; i++) {
				for (int j = 0; j < x; j++) {
					_data[i][j] = 1;
				}
			}
		}

		void rotrow(int y, int dx) {
			int j0 = SCREEN_WIDTH - dx, y0 = SCREEN_HEIGHT + y;
			for (int j = 0; j < SCREEN_WIDTH; j++, j0 = (j0 + 1) % SCREEN_WIDTH) {
				_data[y][j] = _data[y0][j0];
			}
			memcpy(_data[y0], _data[y], SCREEN_WIDTH);
		}

		void rotcol(int x, int dy) {
			int i0 = SCREEN_HEIGHT - dy;
			for (int i = SCREEN_HEIGHT; i < SCREEN_HEIGHT<<1;
						i++, i0 = (i0 + 1) % SCREEN_HEIGHT) {
				_data[i][x] = _data[i0][x];
			}
			for (int i = 0; i < SCREEN_HEIGHT; i++) {
				_data[i][x] = _data[SCREEN_HEIGHT + i][x];
			}
		}

	private:
		uint8_t _data[SCREEN_HEIGHT<<1][SCREEN_WIDTH] = {};
};
 
int main()
{
	CombiScreen screen;
	for (string line; getline(cin, line); ) {
		if (line[1] == 'e') { // rect
			int x_pos = line.find('x', 6); // skip "rect ."
			int x = stoi(line.substr(5, x_pos - 5));
			int y = stoi(line.substr(x_pos + 1));
			screen.rect(x, y);
		}
		else if (line[7] == 'r') { // row
			int y_end = line.find(' ', 14); // skip "rotate row y=."
			int y = stoi(line.substr(13, y_end - 13));
			int dx = stoi(line.substr(y_end + 4)); // skip " by "
			screen.rotrow(y, dx);
		}
		else { // column
			int x_end = line.find(' ', 17); // skip "rotate column x=."
			int x = stoi(line.substr(16, x_end - 16));
			int dy = stoi(line.substr(x_end + 4)); // skip " by "
			screen.rotcol(x, dy);
		}
	}
	screen.print();
	cout << "sum: " << screen.sum() << endl;
  return 0;
}
