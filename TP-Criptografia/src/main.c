#include <stdio.h>
#include <string.h>
#include "ecrypt-sync.h"
#include "bpm-file.h"

int main() {
  
	//Abrir archivo bmp

	bmpInfoHeader info;
	unsigned char* img;
	img = LoadBMP("C:\\boca.bmp", &info);
	DisplayInfo(&info);

	//Encriptar
	/*
	 * Comente en el archivo ecrypt-config.h la linea 258 a 268 porque tiraba error de compilacion.
	 */

	ECRYPT_ctx* ctx;
	const u8* ciphertext;
	u8* plaintext;
	u32 msglen = info.imgsize;
	//ECRYPT_init();
	//ECRYPT_keysetup();
	//ECRYPT_ivsetup();
	//ECRYPT_encrypt_bytes();
	//ECRYPT_encrypt_packet();
	//ECRYPT_keystream_bytes()
	return 0;
}
