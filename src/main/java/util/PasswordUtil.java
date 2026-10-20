package util;

import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * 비밀번호 해싱(PBKDF2WithHmacSHA256). 외부 라이브러리(bcrypt 등) 없이 JDK 표준 API만으로
 * 구현했다 - 반복 횟수를 충분히 크게 줘서(12만 회) bcrypt와 비슷한 수준의 brute-force 저항을 갖는다.
 *
 * 저장 형식(VARCHAR2(100)에 들어감, 실제 길이는 iterations 자릿수+salt 24자+hash 44자+콜론 2개 ≈ 76자):
 *   "{iterations}:{salt(Base64)}:{hash(Base64)}"
 */
public class PasswordUtil {

	private static final int ITERATIONS = 120_000;
	private static final int KEY_LENGTH_BITS = 256;
	private static final int SALT_LENGTH_BYTES = 16;

	public static String hash(String plainPassword) {

		byte[] salt = new byte[SALT_LENGTH_BYTES];
		new SecureRandom().nextBytes(salt);

		byte[] hash = pbkdf2(plainPassword.toCharArray(), salt, ITERATIONS);

		return ITERATIONS + ":" + Base64.getEncoder().encodeToString(salt)
				+ ":" + Base64.getEncoder().encodeToString(hash);
	}

	//stored가 아직 해시 형식이 아니면(= 과거 평문 비밀번호가 남아있으면) 무조건 false를 돌려준다.
	//이 프로젝트는 마이그레이션 때 기존 평문 비밀번호를 전부 해시로 바꿔뒀으므로 정상 운영 중에는
	//이 경로를 탈 일이 없지만, 방어적으로 남겨둔다.
	public static boolean verify(String plainPassword, String stored) {

		if (plainPassword == null || stored == null) {
			return false;
		}

		String[] parts = stored.split(":");

		if (parts.length != 3) {
			return false;
		}

		try {
			int iterations = Integer.parseInt(parts[0]);
			byte[] salt = Base64.getDecoder().decode(parts[1]);
			byte[] expected = Base64.getDecoder().decode(parts[2]);
			byte[] actual = pbkdf2(plainPassword.toCharArray(), salt, iterations);
			return slowEquals(expected, actual);
		} catch (Exception e) {
			return false;
		}
	}

	private static byte[] pbkdf2(char[] password, byte[] salt, int iterations) {
		try {
			PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, KEY_LENGTH_BITS);
			SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
			return factory.generateSecret(spec).getEncoded();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	//타이밍 공격 방지 - 어디서 처음 달랐는지가 비교에 걸린 시간으로 새어나가지 않도록
	//끝까지 전부 비교한 뒤 한 번에 같은지 판단한다.
	private static boolean slowEquals(byte[] a, byte[] b) {
		if (a.length != b.length) {
			return false;
		}
		int diff = 0;
		for (int i = 0; i < a.length; i++) {
			diff |= a[i] ^ b[i];
		}
		return diff == 0;
	}

}
