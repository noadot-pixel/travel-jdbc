package util;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.safety.Safelist;

/**
 * 에디터(Quill)가 만든 HTML을 저장하기 전에 한 번 걸러주는 도구.
 * 에디터 툴바가 허용하는 서식(굵게/기울임/밑줄, 제목 H1~H3, 목록, 링크, 이미지)만 통과시키고
 * 그 외(<script>, onclick 같은 이벤트 속성, javascript: 링크 등)는 전부 제거한다.
 *
 * 클라이언트(JS) 쪽에서 에디터 툴바를 그렇게 만들어뒀다고 해서 안전한 게 아니다 - 누구든
 * 브라우저를 거치지 않고 폼 값을 직접 조작해 보낼 수 있으므로, 실제 안전장치는 항상 여기(서버)다.
 */
public class HtmlSanitizer {

	//img는 src에 프로토콜 제한을 걸지 않는다 - 본문 이미지는 "/upload/post/xxx.png"처럼
	//프로토콜 없는 상대 경로라서, addProtocols와 preserveRelativeLinks를 같이 쓰면(jsoup
	//1.18.1에서 실제로 확인됨) 상대 경로가 오히려 전부 지워져 버린다. 대신 <img src="...">는
	//어떤 프로토콜을 넣어도 코드가 실행되지는 않으므로(현대 브라우저 전부 해당) 막을 필요가
	//없고, 실제 위험한 건 <a href="javascript:...">처럼 클릭 시 실행되는 링크라서 a는 그대로 막는다.
	private static final Safelist SAFELIST = new Safelist()
			.addTags("p", "br", "strong", "em", "u", "h1", "h2", "h3", "ol", "ul", "li", "a", "img")
			.addAttributes("a", "href")
			.addAttributes("img", "src", "alt")
			.addProtocols("a", "href", "http", "https", "mailto")
			.addEnforcedAttribute("a", "target", "_blank")
			.addEnforcedAttribute("a", "rel", "nofollow noopener noreferrer");

	public static String clean(String html) {

		if (html == null) {
			return "";
		}

		Document.OutputSettings outputSettings = new Document.OutputSettings().prettyPrint(false);

		String cleaned = Jsoup.clean(html, "", SAFELIST, outputSettings);

		//base64로 통째로 박힌 이미지(data: URI)는 지운다. 정상적인 경로라면 에디터가 항상
		//업로드 API를 거쳐 "/upload/post/xxx.jpg" 같은 짧은 경로만 보내므로, data: URI가
		//왔다는 건 에디터의 붙여넣기/드래그 가로채기를 우회했거나(아주 오래된 캐시된 페이지 등)
		//폼 값을 직접 조작했다는 뜻이다. 그대로 두면 CLOB 하나가 수 MB까지 불어날 수 있다.
		Document doc = Jsoup.parse(cleaned);
		doc.outputSettings(outputSettings);

		for (Element img : doc.select("img[src^=data:]")) {
			img.remove();
		}

		return doc.body().html();
	}

	//본문 안 첫 번째 이미지 주소. 목록 카드 썸네일로 쓴다(별도 "사진 첨부" 필드가 없어졌으므로).
	//이미지가 하나도 없으면 null - 호출하는 쪽에서 국가별 기본 이미지로 대체한다.
	public static String firstImageSrc(String html) {

		if (html == null) {
			return null;
		}

		Element img = Jsoup.parse(html).select("img").first();

		return img == null ? null : img.attr("src");
	}

	//에디터(Quill)는 내용이 없어도 "<p><br></p>" 같은 빈 태그를 보내므로, 문자열이 비었는지가
	//아니라 실제 글자나 이미지가 있는지로 "본문을 썼는지"를 판단해야 한다.
	public static boolean isBlank(String html) {

		if (html == null) {
			return true;
		}

		Document doc = Jsoup.parse(html);

		return doc.text().trim().isEmpty() && doc.select("img").isEmpty();
	}

}
