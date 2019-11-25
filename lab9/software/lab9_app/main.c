/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// unsigned char charToHex(unsigned char c);
// unsigned char charsToHex(unsigned char c1,unsigned char c2);
// void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key);
// void Key_Expansion(unsigned char* initial_key, unsigned int* key_schedule);
// void Key_Expansion_One(unsigned int* key_schedule, unsigned int* old_key, int index);
// void Sub_Byte_msg(unsigned char* msg);
// unsigned char Sub_Byte(unsigned char input);
// void Add_Round_Key(unsigned int* key_schedule,unsigned char* msg,int index );
// void Shift_Rows(unsigned char* msg);
// void Mix_Columns(unsigned char* msg);
// void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key);
// void print_byte(char* print_message, unsigned char* stuff);
// void print_int(char* print_message, unsigned int* stuff);
//
// void print_byte(char* print_message, unsigned char* stuff){
// 	printf("%s\n", print_message);
// 	printf("%02x  %02x  %02x  %02x\n",stuff[0],stuff[4],stuff[8],stuff[12]);
// 	printf("%02x  %02x  %02x  %02x\n",stuff[1],stuff[5],stuff[9],stuff[13]);
// 	printf("%02x  %02x  %02x  %02x\n",stuff[2],stuff[6],stuff[10],stuff[14]);
// 	printf("%02x  %02x  %02x  %02x\n",stuff[3],stuff[7],stuff[11],stuff[15]);
// }
//
// void print_int(char* print_message, unsigned int* stuff){
// 	printf("%s\n", print_message);
// 	printf("first column is %08x\n", stuff[0]);
// 	printf("second column is %08x\n", stuff[1]);
// 	printf("third column is %08x\n", stuff[2]);
// 	printf("fourth column is %08x\n", stuff[3]);
// }

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000040;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
unsigned char charToHex(unsigned char c)
{
	unsigned char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
unsigned char charsToHex(unsigned char c1,unsigned char c2)
{
	unsigned char hex1 = charToHex(c1);
	unsigned char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

unsigned char Sub_Byte(unsigned char input){
	return aes_sbox[input];
}

void Key_Expansion_One(unsigned int* key_schedule, unsigned int* old_key, int index){
	int i;
	unsigned char last_word_bytes[4];
	unsigned int bitmask = 0xFF000000;
	unsigned char subword_bytes[4];
	unsigned char temp_bytes[4];
	unsigned int new_word1, new_word2, new_word3, new_word4;

	// printf("the old_key[3] in Key_Expansion_One is %08x\n", old_key[3]);
	for (i=0; i<4; i++){
		last_word_bytes[i]= (unsigned char)((old_key[3] & (bitmask >> i*8)) >> (3-i)*8);
		subword_bytes[i]= Sub_Byte(last_word_bytes[i]);
	}

	// printf("last_word_bytes is %02x  %02x  %02x  %02x\n", last_word_bytes[0],last_word_bytes[1],last_word_bytes[2],last_word_bytes[3]);
	// printf("subword_bytes is %02x  %02x  %02x  %02x\n", subword_bytes[0],subword_bytes[1],subword_bytes[2],subword_bytes[3]);

	temp_bytes[0]= subword_bytes[1];
	temp_bytes[1]= subword_bytes[2];
	temp_bytes[2]= subword_bytes[3];
	temp_bytes[3]= subword_bytes[0];

	// printf("temp_bytes is %02x  %02x  %02x  %02x\n", temp_bytes[0],temp_bytes[1],temp_bytes[2],temp_bytes[3]);

	new_word1= (unsigned int)((temp_bytes[0]<< 24)+ (temp_bytes[1]<< 16)+ (temp_bytes[2]<< 8)+ (temp_bytes[3])) ^ Rcon[index] ^ old_key[0];
	new_word2= new_word1 ^ old_key[1];
	new_word3= new_word2 ^ old_key[2];
	new_word4= new_word3 ^ old_key[3];

	// printf("new_word1 is %08x\n", new_word1);
	// printf("new_word2 is %08x\n", new_word2);
	// printf("new_word3 is %08x\n", new_word3);
	// printf("new_word4 is %08x\n", new_word4);

	key_schedule[index*4]= new_word1;
	key_schedule[index*4+1]= new_word2;
	key_schedule[index*4+2]= new_word3;
	key_schedule[index*4+3]= new_word4;

	return;
}

// helper function for encrypt
void Key_Expansion(unsigned char* initial_key, unsigned int* key_schedule){
	int i,j;
	unsigned int old_key[4];

	for (i=0; i<4; i++){
		key_schedule[i]= (unsigned int)((initial_key[4*i]<< 24) + (initial_key[4*i+1]<< 16) + (initial_key[4*i+2]<< 8) +initial_key[4*i+3]);
	}

	// print_int("the initial key schedule is ",key_schedule);
	for (i=1; i<11; i++){
		for(j=0;j<4;j++){
			old_key[j]= key_schedule[(i-1)*4+j];
		}
		// printf("at %d time \n",i);
		// printf("the old_key[0] in Key_Expansion is %08x\n", old_key[0]);
		// printf("the old_key[1] in Key_Expansion is %08x\n", old_key[1]);
		// printf("the old_key[2] in Key_Expansion is %08x\n", old_key[2]);
		// printf("the old_key[3] in Key_Expansion is %08x\n", old_key[3]);

		Key_Expansion_One(key_schedule, old_key,i);
		// print_int("old key is ",old_key);
		// print_int("key schedule at that position is ", key_schedule+(i*4));
	}

	return;
}





void Sub_Byte_msg(unsigned char* msg){
	int i;

	for (i=0; i<16; i++){
		msg[i]=Sub_Byte(msg[i]);
	}
}


void Add_Round_Key(unsigned int* key_schedule,unsigned char* msg,int index ){
	int i;
	unsigned int msg_helper;
	unsigned int keyword[4];
	unsigned int bitmask = 0xFF000000;

	for(i=0; i<4; i++){
		keyword[i] = key_schedule[index*4+i];
	}

	for(i=0; i<4; i++){
		msg_helper=(unsigned int)((msg[i*4]<< 24)+ (msg[i*4+1]<< 16)+ (msg[i*4+2]<< 8) +(msg[i*4+3]));
		msg_helper ^= keyword[i];
		msg[i*4]= (unsigned char)((bitmask & msg_helper) >> 24 );
		msg[i*4+1]= (unsigned char)(((bitmask >> 8) & msg_helper) >> 16);
		msg[i*4+2]= (unsigned char)(((bitmask >> 16) & msg_helper) >> 8);
		msg[i*4+3]= (unsigned char)((bitmask >> 24) & msg_helper);
	}

	return;
}

void Shift_Rows(unsigned char* msg){
	unsigned char helper1, helper2, helper3, helper4;
	helper1= msg[1];
	helper2= msg[5];
	helper3= msg[9];
	helper4= msg[13];

	msg[1]= helper2;
	msg[5]= helper3;
	msg[9]= helper4;
	msg[13]= helper1;

	helper1= msg[2];
	helper2= msg[6];
	helper3= msg[10];
	helper4= msg[14];

	msg[2]= helper3;
	msg[6]= helper4;
	msg[10]= helper1;
	msg[14]= helper2;

	helper1= msg[3];
	helper2= msg[7];
	helper3= msg[11];
	helper4= msg[15];

	msg[3]= helper4;
	msg[7]= helper1;
	msg[11]= helper2;
	msg[15]= helper3;

}

void Mix_Columns(unsigned char* msg){
	int i;
	unsigned char new_byte1,new_byte2,new_byte3,new_byte4;
	for (i=0; i<4; i++){
		new_byte1=gf_mul[msg[i*4]][0] ^ gf_mul[msg[i*4+1]][1] ^ msg[i*4+2] ^ msg[i*4+3];
		new_byte2=msg[i*4] ^ gf_mul[msg[i*4+1]][0] ^ gf_mul[msg[i*4+2]][1] ^ msg[i*4+3];
		new_byte3=msg[i*4] ^ msg[i*4+1] ^ gf_mul[msg[i*4+2]][0] ^ gf_mul[msg[i*4+3]][1];
		new_byte4=gf_mul[msg[i*4]][1] ^ msg[i*4+1] ^ msg[i*4+2] ^ gf_mul[msg[i*4+3]][0];
		msg[i*4]=new_byte1;
		msg[i*4+1]=new_byte2;
		msg[i*4+2]=new_byte3;
		msg[i*4+3]=new_byte4;
	}
	return;
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	int i;
	unsigned char msg[16];
	unsigned char key_input[16];
	unsigned int key_schedule[44];

	for (i=0; i<16; i++){
		msg[i]=charsToHex(msg_ascii[i*2],msg_ascii[i*2+1]);
		key_input[i]=charsToHex(key_ascii[i*2],key_ascii[i*2+1]);
	}

	Key_Expansion(key_input,key_schedule);
	Add_Round_Key(key_schedule,msg,0);

	for(i=1; i<10; i++){
		Sub_Byte_msg(msg);
		Shift_Rows(msg);
		Mix_Columns(msg);
		Add_Round_Key(key_schedule,msg,i);
	}
	Sub_Byte_msg(msg);
	Shift_Rows(msg);
	Add_Round_Key(key_schedule,msg,10);

	for (i=0; i<4; i++){
		key[i] =(unsigned int)((key_input[4*i]<< 24) + (key_input[4*i+1]<< 16) +(key_input[4*i+2]<< 8) +key_input[4*i+3]);
	}
	for (i=0; i<4; i++){
		msg_enc[i] =(unsigned int)((msg[4*i]<< 24) + (msg[4*i+1]<< 16) + (msg[4*i+2]<< 8) + msg[4*i+3]);
	}

	for (i=0; i<4; i++){
		AES_PTR[i]=key[i];
	}
    // may add something here
	for (i=0; i<4; i++){
		AES_PTR[i+4]= msg_enc[i];
	}
	return;
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
//	int i;
//
//	for(i=4; i<8; i++){
//		AES_PTR[i] = msg_enc[i-4];
//	}
//	AES_PTR[14] = AES_PTR[14] | 0x00000001;
//
//	if((AES_PTR[15] & 0x00000001) == 0x00000001){
//		for(i=8; i<12; i++){
//			msg_dec[i-8] = AES_PTR[i];
//		}
//	}
//	AES_PTR[14] = AES_PTR[14] | 0X00000001;

	AES_PTR[14] = 1;
	while (AES_PTR[15] == 0){
		// do nothing
	}

	msg_dec[0] = AES_PTR[8];
	msg_dec[1] = AES_PTR[9];
	msg_dec[2] = AES_PTR[10];
	msg_dec[3] = AES_PTR[11];

	AES_PTR[14] = 0;

	return;
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}