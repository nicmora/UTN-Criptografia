#include <stdio.h>
#include <string.h>
#include "ecrypt-sync.h"
#include "bpm-file.h"

int main() {
  
	//Abrir archivo bmp

	bmpInfoHeader info;
	char *plaintext;
	plaintext = LoadBMP("C:\\boca.bmp", &info);
	DisplayInfo(&info);

	//Encriptar
	/*
	 * Comente en el archivo ecrypt-config.h la linea 258 a 268 porque tiraba error de compilacion.
	 */

	//Como Cifrar
	ECRYPT_ctx ctx;
	u8 key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78,0x9a,0xbc,0xde,0xf0},
		IV[12] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,0x12,0x34,0x56,0x78};
	u32 msglen = info.imgsize;
	char ciphertext[msglen];
	ECRYPT_init();
	ECRYPT_keysetup(&ctx,key,128,96);
	ECRYPT_ivsetup(&ctx,IV);
	ECRYPT_encrypt_bytes(&ctx,plaintext,ciphertext,msglen);
	SaveBMP("C:\\boca.bmp", ciphertext, msglen);

	//Como Descifrar
	/*ECRYPT_ctx ctx2;
	u32 msglen2 = strlen(ciphertext);
	char plaintext2[msglen2];
	ECRYPT_init();
	ECRYPT_keysetup(&ctx2,key,128,96);
	ECRYPT_ivsetup(&ctx2,IV);
	ECRYPT_decrypt_bytes(&ctx2,ciphertext,plaintext2,12);*/

	exit(0);
}
