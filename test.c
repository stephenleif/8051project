#include <reg51.h>

sbit allowable = P1^0;
sbit rs = P0^0;
sbit rw = P0^1;
sbit en = P0^2;
sbit buzzer = P1^1;

void lcddta(unsigned char[], unsigned char);
void lcdcmd(unsigned char);
void msdelay(unsigned int);

void main(void) {
  lcdcmd(0x38);
  lcdcmd(0x0c);
  lcdcmd(0x06);
  lcdcmd(0x01);

  while (1) {
    lcdcmd(0x80); // Set cursor to the beginning of the first line

    if (allowable == 1) {
      lcddta("Tank is okay", 12);
      buzzer = 0; // Turn off the buzzer
    } else {
      lcddta("Tank needs refill", 17);
      buzzer = 1; // Turn on the buzzer
    }

    msdelay(500); // Wait for 500ms
    lcdcmd(0x01); // Clear the LCD screen
  }
}

void lcdcmd(unsigned char cmd) {
  P2 = cmd;
  rs = 0; // Command mode
  rw = 0; // Write mode
  en = 1; // Enable LCD
  msdelay(5);
  en = 0;
}

void lcddta(unsigned char a[], unsigned char len) {
  unsigned char x;
  for (x = 0; x < len; x++) {
    P2 = a[x];
    rs = 1; // Data mode
    rw = 0; // Write mode
    en = 1; // Enable LCD
    msdelay(5);
    en = 0;
  }
}

void msdelay(unsigned int a) {
  unsigned int x, y;
  for (x = 0; x < a; x++) {
    for (y = 0; y < 1275; y++);
  }
}