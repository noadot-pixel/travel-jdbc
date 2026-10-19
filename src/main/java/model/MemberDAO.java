package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * MEMBERS 테이블을 다루는 DAO. SQL을 실행하는 코드는 전부 여기에 모은다.
 * ID 컬럼 = 로그인 아이디 = 이메일 (MemberDTO 설명 참고).
 */
public class MemberDAO {

	//BIRTHDAY는 날짜 계산을 할 일이 없는 단순 표시용 값이라 DATE가 아니라 VARCHAR2(10)로 저장한다
	//(그대로 "YYYY-MM-DD" 문자열로 넣고 꺼내면 돼서 TO_CHAR/TO_DATE 변환이 필요 없다)
	private static final String COLUMNS =
			"ID, PWD, NICKNAME, ADMIN_LEVEL, TO_CHAR(JOIN_DATE, 'YYYY-MM-DD') JOIN_DATE, "
		  + "BIO, COUNTRY, COUNTRY_OTHER, REAL_NAME, NAME_PUBLIC, "
		  + "BIRTHDAY, BIRTHDAY_PUBLIC, PHOTO_PATH, GENDER, GENDER_PUBLIC, SUSPENDED, DARK_MODE ";

	private MemberDTO toDto(ResultSet rs) throws Exception {

		MemberDTO dto = new MemberDTO();
		dto.setId(rs.getString("ID"));
		dto.setNickname(rs.getString("NICKNAME"));
		dto.setAdminLevel(rs.getInt("ADMIN_LEVEL"));
		dto.setJoinDate(rs.getString("JOIN_DATE"));
		dto.setBio(rs.getString("BIO"));
		dto.setCountry(rs.getString("COUNTRY"));
		dto.setCountryOther(rs.getString("COUNTRY_OTHER"));
		dto.setRealName(rs.getString("REAL_NAME"));
		dto.setNamePublic(!"N".equals(rs.getString("NAME_PUBLIC")));
		dto.setBirthday(rs.getString("BIRTHDAY"));
		dto.setBirthdayPublic(!"N".equals(rs.getString("BIRTHDAY_PUBLIC")));
		dto.setPhotoPath(rs.getString("PHOTO_PATH"));
		dto.setGender(rs.getString("GENDER"));
		dto.setGenderPublic(!"N".equals(rs.getString("GENDER_PUBLIC")));
		dto.setSuspended("Y".equals(rs.getString("SUSPENDED")));
		dto.setDarkMode("Y".equals(rs.getString("DARK_MODE")));
		// PWD는 세션에 들고 다닐 필요가 없으므로 DTO에 담지 않는다.
		return dto;
	}

	//아이디(이메일) 중복 확인 - 이미 있으면 true
	public boolean idCheck(String id) {

		String sql = "select id from members where id = ?";

		boolean isDuplicate = false;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				isDuplicate = rs.next();
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return isDuplicate;
	}

	//회원가입 - 성공하면 1, 실패하면 0
	public int join(MemberDTO dto) {

		String sql = "insert into members(id, pwd, nickname, gender) values(?, ?, ?, ?)";
		//나머지 컬럼은 전부 DEFAULT(ADMIN_LEVEL=0, JOIN_DATE=SYSDATE)거나 NULL 허용이라 안 넣어도 된다.

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, dto.getId());
			pstmt.setString(2, dto.getPwd());
			pstmt.setString(3, dto.getNickname());
			pstmt.setString(4, dto.getGender());
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	//로그인 - 아이디/비밀번호가 맞으면 전체 프로필을, 틀리면 null을 돌려준다.
	public MemberDTO login(String id, String pwd) {

		String sql = "select " + COLUMNS + "from members where id = ? and pwd = ?";

		MemberDTO dto = null;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, id);
			pstmt.setString(2, pwd);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					dto = toDto(rs);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return dto;
	}

	//회원 하나 다시 조회 (프로필 저장 뒤 세션을 최신 값으로 다시 채울 때 사용)
	public MemberDTO getById(String id) {

		String sql = "select " + COLUMNS + "from members where id = ?";

		MemberDTO dto = null;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					dto = toDto(rs);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return dto;
	}

	//프로필 수정 - 본인 계정만 수정하므로 where에 id까지 건다 (세션의 id만 써야 함, 화면 값 금지)
	public int update(MemberDTO dto) {

		String sql = "update members set "
				   + "nickname = ?, bio = ?, country = ?, country_other = ?, "
				   + "real_name = ?, name_public = ?, birthday = ?, birthday_public = ?, photo_path = ?, "
				   + "gender = ?, gender_public = ? "
				   + "where id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, dto.getNickname());
			pstmt.setString(2, dto.getBio());
			pstmt.setString(3, dto.getCountry());
			pstmt.setString(4, dto.getCountryOther());
			pstmt.setString(5, dto.getRealName());
			pstmt.setString(6, dto.isNamePublic() ? "Y" : "N");
			//생일을 비워서 저장하면 null로 들어가도록 빈 문자열은 null로 바꾼다.
			String birthday = (dto.getBirthday() == null || dto.getBirthday().isEmpty()) ? null : dto.getBirthday();
			pstmt.setString(7, birthday);
			pstmt.setString(8, dto.isBirthdayPublic() ? "Y" : "N");
			pstmt.setString(9, dto.getPhotoPath());
			pstmt.setString(10, dto.getGender());
			pstmt.setString(11, dto.isGenderPublic() ? "Y" : "N");
			pstmt.setString(12, dto.getId());
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	//세션에 들고 있는 loginMember.isSuspended()는 로그인했을 때 값 그대로 캐시돼 있어서,
	//관리자가 로그인 중인 회원을 그 자리에서 정지시켜도 당장 반영되지 않는다(재로그인해야 반영됨).
	//댓글/좋아요/글쓰기처럼 막아야 하는 행동 직전에는 이걸로 DB 값을 다시 확인한다.
	public boolean isSuspendedNow(String id) {

		String sql = "select suspended from members where id = ?";

		boolean suspended = false;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, id);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					suspended = "Y".equals(rs.getString("suspended"));
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return suspended;
	}

	//다크모드 켜기/끄기 - 전체 프로필 저장 폼과 별개로, 마이페이지에서 클릭하면 바로 반영된다.
	public int setDarkMode(String id, boolean on) {

		String sql = "update members set dark_mode = ? where id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, on ? "Y" : "N");
			pstmt.setString(2, id);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	//관리자 화면용 전체 회원 목록 (가입일 최신순)
	public List<MemberDTO> getAllMembers() {

		String sql = "select " + COLUMNS + "from members order by join_date desc";

		List<MemberDTO> list = new ArrayList<MemberDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql);
			 ResultSet rs = pstmt.executeQuery()) {

			while (rs.next()) {
				list.add(toDto(rs));
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return list;
	}

	//관리자가 특정 회원을 활동 정지/해제한다.
	public int setSuspended(String id, boolean suspended) {

		String sql = "update members set suspended = ? where id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, suspended ? "Y" : "N");
			pstmt.setString(2, id);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	//admin이 특정 회원의 권한 레벨을 바꾼다 (0=일반회원, 1=moderator, 2=admin).
	public int setAdminLevel(String id, int level) {

		String sql = "update members set admin_level = ? where id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, level);
			pstmt.setString(2, id);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

}
