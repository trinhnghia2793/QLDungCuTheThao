--====================================================================================================================
--TRANG WEB QUẢN LÝ MUA BÁN DỤNG CỤ THỂ THAO (DB_DUNGCUTHETHAO)
CREATE DATABASE DB_DUNGCUTHETHAO
GO

USE DB_DUNGCUTHETHAO
GO

--====================================================================================================================
--product_category
CREATE TABLE product_category
(
	product_category_id INT IDENTITY(1, 1),
	product_category_name NVARCHAR(255),
	product_category_description NVARCHAR(MAX),

	CONSTRAINT PK_product_category Primary Key (product_category_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--product
CREATE TABLE product
(
	product_id INT IDENTITY(1, 1),
	product_category_id INT,
	product_name NVARCHAR(255),
	product_description NVARCHAR(MAX),
	product_thumbnail_image NVARCHAR(255),
	product_price DECIMAL(18, 0),
	product_discount DECIMAL(18, 0),
	product_review_positive INT,
	product_review_negative INT,
	product_bought_count INT,
	product_inventory INT,

	CONSTRAINT PK_product Primary Key (product_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--product_image
CREATE TABLE product_image
(
	product_image_id INT IDENTITY(1, 1),
	product_id INT,
	product_image_file_name NVARCHAR(50),

	CONSTRAINT PK_product_image Primary Key (product_image_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--user_account
CREATE TABLE user_account
(
	user_account_id INT IDENTITY(1, 1),
	user_username VARCHAR(255),
	user_password VARCHAR(255),
	user_gender NVARCHAR(10),
	user_email VARCHAR(255),
	user_phonenumber CHAR(12),
	user_address NVARCHAR(MAX),
	user_firstname NVARCHAR(255),
	user_lastname NVARCHAR(255),
	user_member_tier NVARCHAR(255),
	user_point INT,

	CONSTRAINT PK_user_account Primary Key (user_account_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--user_order
CREATE TABLE user_order
(
	user_order_id INT IDENTITY(1, 1),
	user_account_id INT,
	order_time DATETIME,
	user_order_buyer_name NVARCHAR(255),
	user_order_address NVARCHAR(255),
	user_order_email VARCHAR(255),
	user_order_phonenumber CHAR(12),
	is_processed BIT, -- đang xử lý false
	is_delivered BIT, -- đang vận chuyển
	is_payment BIT, -- false tien mat, true thanh toan online
	is_paid BIT, -- TRUE ĐÃ THANH TOÁN, FALSE CHƯA THANH TOÁN
	order_total_value DECIMAL(18, 0),

	CONSTRAINT PK_user_order Primary Key (user_order_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--user_order_product
CREATE TABLE user_order_product
(
	user_order_id INT,
	product_id INT, 
	product_name nvarchar(255),
	order_product_amount INT,

	CONSTRAINT PK_user_order_product Primary Key (user_order_id, product_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--product_review
CREATE TABLE product_review
(
	product_review_id INT IDENTITY(1, 1),
	user_account_id INT,
	product_id INT,
	product_review_content NVARCHAR(MAX),
	review_owner NVARCHAR(255),

	CONSTRAINT PK_product_review Primary Key (product_review_id)
)
GO

----------------------------------------------------------------------------------------------------------------------
--admin_account
create table admin_account
(
	admin_account_id INT IDENTITY(1,1) not null,
	admin_username NVARCHAR(50) UNIQUE,
	admin_password VARCHAR(50),
	CONSTRAINT PK_ADMIN_ACCOUNT PRIMARY KEY(admin_account_id,admin_username)
)
GO

----------------------------------------------------------------------------------------------------------------------
--Các tham chiếu khóa ngoại

ALTER TABLE product
ADD CONSTRAINT FK_product_product_category Foreign Key (product_category_id) REFERENCES product_category (product_category_id)

ALTER TABLE product_image
ADD CONSTRAINT FK_product_image_product Foreign Key (product_id) REFERENCES product (product_id)

ALTER TABLE user_order
ADD CONSTRAINT FK_user_order_user_account Foreign Key (user_account_id) REFERENCES user_account (user_account_id)

ALTER TABLE user_order_product
ADD CONSTRAINT FK_user_order_product_user_order Foreign Key (user_order_id) REFERENCES user_order (user_order_id),
	CONSTRAINT FK_user_order_product_product Foreign Key (product_id) REFERENCES product (product_id)

ALTER TABLE product_review
ADD CONSTRAINT FK_product_review_user_account Foreign Key (user_account_id) REFERENCES user_account (user_account_id),
	CONSTRAINT FK_product_review_product Foreign Key (product_id) REFERENCES product (product_id)

GO

INSERT INTO product_category (product_category_name,product_category_description)
VALUES (N'Bóng Đá & Futsal',N'Bóng đá trong nhà hay Futsal là một loại hình bóng đá thi đấu bên trong nhà thi đấu, có thể được xem như là một dạng của bóng đá sân nhỏ.'),
(N'BÓNG CHUYỀN & BÓNG CHUYỀN BÃI BIỂN',N'Bóng chuyền bãi biển là một môn thể thao giữa 2 đội với 2 thành viên mỗi đội, với luật gốc từ môn bóng chuyền truyền thống, và đã trở thành một môn thể thao ở thế vận hội từ năm 1996.'),
(N'BÓNG BẦU DỤC & BÓNG ĐÁ MỸ',N'Bóng bầu dục Mỹ hay còn gọi là bóng đá kiểu Mỹ, tiếng lóng Việt Nam gọi là bóng cà na, là một môn thể thao thi đấu đồng đội phổ biến tại Hoa Kỳ.'),
(N'BÓNG CHÀY',N'Bóng chày là một môn thể thao đồng đội. được chơi giữa hai đội, mỗi đội chín người, thay phiên nhau phòng thủ và tấn công.'),
(N'CẦU LÔNG',N'Cầu lông hay vũ cầu là môn thể thao dùng vợt thi đấu giữa 2 vận động viên hoặc 2 cặp vận động viên trên 2 nửa của sân cầu hình chữ nhật được chia ra bằng tấm lưới ở giữa.')
GO

INSERT INTO product(product_category_id,product_name,product_description,product_thumbnail_image,product_price,product_discount,product_review_positive,product_review_negative,product_bought_count,product_inventory)
VALUES(1, N' Giày đá bóng sân cỏ nhân tạo Viralto I TF', N'Giày đá bóng Viralto I để chơi bóng trên nền đất khô tự nhiên hoặc sân cỏ nhân tạo ngắn với tần suất 3 lần/tuần. Bạn muốn cảm giác chân thoải mái tối đa để trình diễn những động tác đẹp nhất? Đôi giày Viralto I, với thân trên làm bằng da PU mềm, đế linh hoạt Flex-H, và lớp đệm EVA là lựa chọn hoàn hảo cho bạn!', N'viraltoITF.jpg', 1095000, 0, 0, 0, 0, 100),
(1, N' Tất đá bóng chống trượt Viralto MiD', N'Đôi  tất đá bóng cổ vừa hiệu suất cao này phù hợp với những cầu thủ bóng đá khó tính nhất. Thoải mái. Chuyên dụng. Hiệu suất cao. Tất đến giữa bắp chân, có thành phần chống trượt hiệu quả, hoàn hảo cho tập luyện và thi đấu!', N'tatViraltoMiD.jpeg', 245000, 0, 0, 0, 0, 100),
(1, N' Áo thun đá bóng F100 cho người lớn', N'Áo thun đá bóng F100 dành cho người lớn tập luyện và thi đấu lên đến hai lần một tuần. Áo thun đá bóng F100 nhẹ và thoáng khí để bạn di chuyển dễ dàng khắp sân.', N'aoF100D.jpeg', 145000, 0, 0, 0, 0, 100),
(1, N'Túi thể thao Essential 35L ', N'Túi thể thao đeo vai Essential giúp bạn mang theo tất cả các dụng cụ thể thao. Gấp gọn vào một ngăn của túi để bảo quản dễ dàng. Bạn không biết nên cất túi vào đâu sau khi sử dụng? Chúng tôi tạo ra chiếc túi đeo vai này với thiết kế nhỏ gọn và bền bỉ. Gấp gọn vào một ngăn của túi để bảo quản dễ dàng tại nhà.', N'tuiEssential.jpeg', 275000, 0, 0, 0, 0, 100),
(1, N'Balô thể thao nhỏ gọn· Essential 17L', N'Balo thể thao 17L Essential được thiết kế với nhiều ngăn, giúp việc di chuyển thường ngày đến phòng tập và tham gia hoạt động của bạn trở nên dễ dàng hơn. Bạn đang tìm kiếm một mẫu balô thiết thực để mang đến phòng tập hay phục vụ các hoạt động thể thao? Balô Essential 17L được thiết kế với một ngăn chính lớn và nhiều ngăn phụ, trong đó có một ngăn đựng giày.', N'baloEssential.jpeg', 245000, 0, 0, 0, 0, 100),
(1, N' Quả bóng đá First Kick cỡ 4 cho trẻ em (9-12 tuổi) - Đỏ', N'Quả bóng đá dành cho các cầu thủ nhí mới tập chơi và chơi không thường xuyên. Đội ngũ thiết kế của chúng tôi hướng sự ưu tiên đến độ bền của vỏ ngoài và độ nảy để bạn có thể bắt đầu tập các động tác đầu tiên của mình.', N'doFirstKick.jpeg', 1095000, 0, 0, 0, 0, 100),
(1, N' Nẹp ống đồng chơi đá bóng F500 cho người lớn - Xanh dương', N'Các nhà thiết kế sản phẩm bóng đá của chúng tôi đã tạo ra nẹp ống đồng F500 đàn hồi thấp này, cùng với ống bọc ngoài, mang nhẹ và bền bỉ. Bạn đang tìm kiếm nẹp ống đồng phù hợp với chân bạn? Chúng tôi đã tạo ra nẹp ống đồng F500 đàn hồi thấp này, cùng với ống bọc ngoài (tất) phù hợp với bất kỳ người chơi nào.', N'nepF500.jpeg', 295000, 0, 0, 0, 0, 100),
(1, N'Tất đá bóng F500 cho Trẻ em - Xanh lá', N'Tất đá bóng F500 dành cho các cầu thủ trẻ chơi ở mức trung cấp để sử dụng hai đến ba lần một tuần khi tập luyện hay thi đấu. Bạn đang tìm kiếm một loại tất đá bóng bền và thoáng khí tốt? Quai co giãn quanh lòng bàn chân mang đến sự hỗ trợ tốt khi chơi trong khi kiểu dệt thoáng khí giúp thông khí cho bàn chân. ', N'TatF500XanhLa.jpg', 125000, 0, 0, 0, 0, 100),
(1, N'Nẹp ống đồng đá bóng Essential 140 cho người lớn - Đen', N' Nẹp ống đồng ESSENTIAL 140 có phần đệm mắt cá đảm bảo độ vừa vặn tối đa. Bạn đang tìm kiếm nẹp ống đồng có phần bảo vệ mắt cá chân? Nhóm thiết kế của chúng tôi đã tạo ra nẹp ống đồng ESSENTIAL 140 này với quai dán và đệm mắt cá chân.','nepEsssentail.jpeg', 225000, 0, 0, 0, 0, 100),
(1, N'Giày đá bóng sân cỏ nhân tạo Agility 100 HG cho người lớn - Đen/Trắng', N'Giày Agility 100 để chơi trên sân cỏ nhân tạo mỗi tuần một lần.Agility 100 FG giúp bạn thực hiện các động tác kỹ thuật đầu tiên trên sân một cách an toàn. "Các đinh giày phân bố đồng đều dọc đế giày giúp cung cấp lực kéo tốt hơn trên các mặt sân cứng hay sân cỏ nhân tạo.Được làm từ PU nhằm đảm bảo giày sẽ chịu được các yêu cầu của một mùa bóng.', N'giayAgility100HG.jpeg', 445000, 0, 0, 0, 0, 100),
(1, N' Khung thành bóng đá bơm hơi Air Kage - Xanh/Đen', N'Để chơi đá bóng cùng gia đình và bạn bè, chúng tôi đã tạo ra khung thành bơm hơi Air Kage Goal này với dụng cụ bơm tích hợp phù hợp cho mọi loại địa hình. Điểm tân tiến của khung thành bóng đá Air Kage chính là máy bơm tích hợp: , lắp và tháo chưa bao giờ dễ dàng và thú vị đến thế.', N'AirKage.jpeg', 1295000, 0, 0, 0, 0, 100),
(1, N' Găng tay thủ môn đá bóng siêu bền First cho trẻ em - Đen/Vàng/Đỏ', N'Găng tay thủ môn với chất liệu cao su latex bền chắc giúp các thủ môn học cách đổ người và bắt bóng. Bạn đang tìm kiếm một đôi găng tay thủ môn có độ bền cao? Chúng tôi tạo ra đôi găng tay First với lớp phủ ngoài bằng cao su latex tổng hợp, giúp hạn chế sờn rách khi đổ người bắt bóng liên tục.', N'gang-tay-first.jpeg', 245000, 0, 0, 0, 0, 100),
(1, N'Áo lót dài tay đá bóng thoáng khí Keepcomfort cho người lớn - Đen', N' Áo lót dài tay đá bóng dành cho những người chơi muốn giữ ấm khi chơi bóng ở cường độ trung bình. Áo lót giữ nhiệt dài tay này giúp bạn thoải mái trên sân cỏ. Sản phẩm này được khuyên dùng ở nhiệt độ từ 7° đến 20°C và khô thoáng mồ hôi để bạn có thể tập trung vào trận đấu.', N'keepcomfort.jpeg', 275000, 0, 0, 0, 0, 100),
(2, N'Áo lót đá bóng giữ nhiệt Keepdry 500 cho người lớn - Đen', N'Áo lót Keepdry nhằm đáp ứng nhu cầu của các cầu thủ bóng đá với khả năng kỹ thuật tầm trung. Áo lót giữ nhiệt Keepdry được khuyên dùng cho nhiệt độ từ 7° đến 20°C. Áo giúp thấm mồ hôi và giữ thân nhiệt trong suốt thời gian dài hoạt động thể chất.', N'aoKeepdry.jpeg', 225000, 0, 0, 0, 0, 100),
(2, N'Túi đựng giày Academic - Đen', N'Túi đựng giày Academic 10L có thể đựng và bảo vệ tối đa 2 đôi giày thể thao. Túi có đáy chống bám nước và giúp giày của bạn khô ráo.', N'tuiAcademic.jpeg', 195000, 0, 0, 0, 0, 100),
(2, N'Quả bóng chuyền V100 cỡ 5 cho người mới bắt đầu - Xanh ngọc', N'Quả bóng chuyền hoàn hảo cho người mới bắt đầu học chơi bóng chuyền. Cảm giác thoải mái và dễ cầm nắm giúp bạn bắt đầu chơi bóng chuyền! Đây là quả bóng hoàn hảo để học các động tác đánh bóng chuyền đầu tiên!', N'bongv100.jpeg', 195000, 0, 0, 0, 0, 100),
(2, N'Ốp bảo vệ đầu gối VKP100 - Đen', N'Ốp bảo vệ đầu gối này giúp người mới chơi học những kỹ thuật đầu tiên của bóng chuyền trong nhà. Đệm đầu gối này phù hợp với mọi vóc dáng cơ thể, mang đến sự thoải mái và bảo vệ để bạn tập luyện bóng chuyền thật an toàn.', N'opVKP100.jpeg', 245000, 0, 0, 0, 0, 100),
(2, N'Áo lót đá bóng giữ nhiệt Keepdry 500 cho người lớn - Trắng', N'Áo lót Keepdry nhằm đáp ứng nhu cầu của các cầu thủ bóng đá với khả năng kỹ thuật tầm trung. Áo lót giữ nhiệt Keepdry được khuyên dùng cho nhiệt độ từ 7° đến 20°C. Áo giúp thấm mồ hôi và giữ thân nhiệt trong suốt thời gian dài hoạt động thể chất.', N'aoKeepdry500.jpeg', 395000, 0, 0, 0, 0, 100),
(2, N'Túi thể thao tiện dụng Hardcase 45L - Đen', N'Túi thể thao Hardcase giúp bạn mang theo đồ thể thao, với một ngăn cứng lớn riêng biệt để đựng giày. Ngăn cứng của túi thể thao Hardcase giúp bạn đựng quần áo thể thao riêng biệt với giày sau buổi tập hoặc trận đấu.', N'tuiHardcase45L.jpeg', 745000, 0, 0, 0, 0, 100),
(2, N'Quần đùi lót đá bóng thoáng khí Keepcomfort cho người lớn - Đen', N'Quần đùi lót đá bóng dành cho những người chơi muốn giữ ấm khi chơi bóng ở cường độ trung bình. Mẫu quần đùi lót này bổ sung thêm một lớp giữ ấm. Sản phẩm này được khuyên dùng ở nhiệt độ từ 7° đến 20°C và khô thoáng mồ hôi để bạn có thể tập trung vào trận đấu.', N'quanKeepcomfort.jpeg', 275000, 0, 0, 0, 0, 100),
(2, N'Đồng hồ bấm giờ Onstart 110 - Đen', N'Đội ngũ đam mê chạy bộ của chúng tôi đã thiết kế chiếc đồng hồ bấm giờ này để tính hiệu suất tập luyện của bạn Lý tưởng cho người mới bắt đầu.', N'Onstart110.jpeg', 245000, 0, 0, 0, 0, 100),
(2, N'Bình nước thể thao 1L - Xám/Đỏ', N'Bình nước để mọi người trong cùng một đội có thể chia sẻ nước uống với nhau, có van uống nước đặc biệt vệ sinh để tránh tiếp xúc với miệng. Bình nước 1L có nắp phẳng và van một chiều. Thiết kế này giúp tạo ra dòng tia nước, tránh mọi tiếp xúc với miệng.', N'Binh1L.jpeg', 145000, 0, 0, 0, 0, 100),
(2, N'Túi đựng bóng 10-14 trái - Đen vàng', N'Chiếc túi có thể chứa đến 14 quả bóng cỡ 5. Chiếc túi có thể chứa đến 14 quả bóng cỡ 5.', N'Tuidung.jpeg', 245000, 0, 0, 0, 0, 100),
(2, N'Đệm bảo vệ đầu gối chơi bóng chuyền V500 - Xanh navy', N'Ốp bảo vệ đầu gối là sự lựa chọn hoàn hảo cho những người thường xuyên tập luyện và thi đấu bóng chuyền trong nhà với tần suất 2-3 lần một tuần. Với niềm đam mê bóng chuyền, đội ngũ thiết kế tại Decathlon đã cho ra đời mẫu ốp bảo vệ đầu gối, mang lại sự bảo vệ tối ưu khi chơi bóng chuyền với tần suất thường xuyên.', N'DemV500.jpeg', 295000, 0, 0, 0, 0, 100),
(2, N'Thang dây Esential Agility 3.2m - Cam', N'Để luyện tập tốc độ cho cầu thủ, chúng tôi tạo ra chiếc thang dài 3,2m với bậc thang cứng để tập luyện phối hợp. Để luyện sải chân cho các cầu thủ, chúng tôi sản xuất ra chiếc thang này dài 3,2m với bậc thang nhựa cứng tương đối có hình mũi tên cùng màu sắc độc đáo , giúp dễ nhận diện trên sân.', N'ThangAgility.jpeg', 295000, 0, 0, 0, 0, 100),
(3, N'Kim bơm bóng cho các môn thể thao đồng đội - Bộ 3 kim', N'Bộ kim này được thiết kế để bơm bất kỳ loại bóng nào bằng bơm tay., Bộ này có 3 kim nhôm có thể lắp vừa bơm tay. Chúng không được thiết kế cho máy bơm chân. Dễ sử dụng, Đầu bằng ren vít 4 mm (đường kính).', N'Kimbom.jpeg', 79000, 0, 0, 0, 0, 100),
(3, N'Bóng bầu dục Mỹ AF 500 cỡ chính thức', N'Bóng được bao trong 4 lớp vỏ đan bằng polyurethane. Vỏ ngoài bằng da tổng hợp (PU) bảo đảm mang đến độ bám tốt cùng đường khâu nổi giúp cải thiện khả năng ném bóng của bạn.', N'Bongbauduc.jpeg', 395000, 0, 0, 0, 0, 100),
(3, N'Túi đựng 8 quả bóng - Đen', N'Túi đựng bóng được thiết kế bền chắc để huấn luyện viên bóng đá dễ dàng bảo quản và vận chuyển tối đa 8 quả bóng cỡ 5 và các phụ kiện nhỏ. Túi đựng bóng này có hệ thống mở/đóng luôn kín trong mọi tình huống. Hơn thế nữa, túi ngoài cho phép bạn mang theo bơm hoặc một bộ áo bib khi cần.', N'Tuidungbong.jpeg', 395000, 0, 0, 0, 0, 100),
(3, N'Khung thành bóng đá SG 500 cỡ 5 - Xanh navy/Đỏ', N'Khung thành bóng đá SG 500 bằng thép. Cỡ S hoàn hảo cho các trận đấu không có thủ môn. Bạn đang tìm kiếm loại khung thành bóng đá kiên cố?Chúng tôi đã tạo ra dòng sản phẩm SG 500 bằng thép.Cỡ S hoàn hảo cho các trận đấu không có thủ môn.', N'Khungthanh.jpeg', 1295000, 0, 0, 0, 0, 100),
(3, N'Đai quấn bó cơ đùi trái/phải Prevent 500 cho nam/nữ', N'Đai quấn bó cơ đùi Prevent 500 được thiết kế nhằm bảo vệ cơ đùi của vận động viên bằng cách tạo lực ép đồng đều. Các dải silicon giúp sản phẩm không trượt xuống khi sử dụng. Vải dệt kim mỏng, thoải mái điều chỉnh theo vóc dáng và dễ dàng mặc bên trong quần short hoặc quần.', N'Daiquanbo.jpeg', 245000, 0, 0, 0, 0, 100),
(3, N'Giày chơi bóng bầu dục trên sân cứng Density R100 FG - Xanh dương/Vàng', N'Nhà thiết kế môn bóng bầu dục của chúng tôi phát triển giày này cho người chơi cần sự thoải mái, độ bám và độ bền khi chơi trên sân cứng 1 hoặc 2 lần một tuần. Đôi giày chơi bóng bầu dục dành cho người lớn này rất thoải mái nhờ vào độ mềm dẻo của các thành phần bên trong nó., Đế giày linh hoạt nhờ vào các gai tròn ngăn vặn xoắn đầu gối và mắt cá chân.', N'Giaybauduc.jpeg', 625000, 0, 0, 0, 0, 100),
(3, N'Bộ 4 cọc nhựa luyện tập Essential 30 cm - Cam', N'Nhóm thiết kế bóng đá chúng tôi đã phát triển những chiếc cọc hình mũi tên này để giúp cho việc luyện tập ở các câu lạc bộ hay ở nhà bạn đơn giản và hiệu quả. Những chiếc cọc bền và ổn định này có thể dùng để đánh dấu khu vực tập luyện.Hình dạng mũi tên của cọc giúp việc tập luyện của bạn trở nên trực quan hơn.', N'Bo4coc.jpeg', 275000, 0, 0, 0, 0, 100),
(3, N'Bộ 3 thanh đánh dấu Modular 80cm - Vàng', N'Các thanh đánh dấu nhẹ và có thể kết hợp theo nhiều cách cho phép bạn chuyển đổi giữa các bài tập của mình chỉ trong vòng vài giây.', N'BoModular.jpeg', 345000, 0, 0, 0, 0, 100),
(3, N'Miếng độn nướu chơi bóng bầu dục Full H 100 cho trẻ em', N'Miếng độn nướu chơi bóng bầu dục này mang đến cho bạn sự bảo vệ răng miệng hiệu quả.', N'Miengdonnuou.jpeg', 89000, 0, 0, 0, 0, 100),
(3, N'Giá xách chai nước loại 6 chai – Đen', N'Giá xách chai nước này được thiết kế để các huấn luyện viên có thể mang theo 6 chai nước ra sân tập. Sản phẩm có thể gấp gọn để dễ dàng cất giữ', N'Giasachchai.jpeg', 325000, 0, 0, 0, 0, 100),
(3, N'Cọc đặt bóng bầu dục mềm - Đen', N'Chúng tôi thiết kế cọc đặt bóng này để đá bóng vào cột gôn trong khi luyện tập và thi đấu. Cọc đặt bóng này giúp cố định bóng rất tốt bất kể vị trí nào, nhờ đó giúp tăng độ chính xác!', N'Cocdatbong.jpeg', 245000, 0, 0, 0, 0, 100),
(3, N'Đệm đùi Lineout chơi bóng bầu dục - Đen', N'Đệm lineout này là sự hỗ trợ hiệu quả cho các cầu thủ nhảy lên tranh bóng. Cầu thủ tranh bóng lineout có thể cải thiện độ cao bật nhảy và thời gian phản ứng của mình.', N'Demdui.jpeg', 445000, 0, 0, 0, 0, 100),
(4, N'Hộp 2 quả bóng chày BA150', N'Bóng làm từ PU và an toàn đối với mọi người dùng. Mang đến cảm giác thực hiện cú ném với bóng được khâu bằng tay. , Bóng có đường may màu đỏ dành riêng cho người mới tập chơi. Người lớn và trẻ em đều có thể chơi bóng an toàn.', N'2bongchay.jpeg', 245000, 0, 0, 0, 0, 100),
(4, N'Gậy bóng chày hợp kim BA150 - Xanh dương', N'Gậy bóng chày hợp kim với kết cấu liền khối lý tưởng cho người mới bắt đầu tập đánh, có trọng lượng trung bình và độ cân bằng tuyệt vời. (cho bóng cứng) Gậy nhôm nhẹ này có diện tích đánh bóng lớn hơn, giúp bạn kiểm soát dễ dàng hơn và đánh bóng , mạnh hơn.(cho bóng cứng)', N'Gaybongchay.jpeg', 1095000, 0, 0, 0, 0, 100),
(4, N'Găng tay trái chơi bóng chày BA100', N'Bạn muốn thử chơi bóng chày? Các nhà thiết kế của chúng tôi đã phát triển găng tay PVC để bạn có thể dễ dàng khám phá , bộ môn thể thao này.', N'GangtayBA100.jpeg', 545000, 0, 0, 0, 0, 100),
(4, N'Găng tay trái chơi bóng chày BA150', N'Nhóm thiết kế của chúng tôi đã phát triển găng tay này với lòng găng bằng da (da heo) giúp bạn chơi , bóng chày ngay lập tức.', N'GangtayBA150.jpeg', 695000, 0, 0, 0, 0, 100),
(4, N'Bóng chày mút xốp BA 100 - Đen/ Đỏ', N'Bạn muốn thử chơi bóng chày? Những nhà thiết kế của chúng tôi đã phát triển một quả bóng bằng mút xốp 100% để bạn có thể tận hưởng việc chơi bóng chày một cách an toàn.', N'BongchayBA100.jpeg', 79000, 0, 0, 0, 0, 100),
(4, N'Bộ sản phẩm chơi bóng chày BA 100 cho Trẻ em', N'Bạn đang tìm kiếm một bộ sản phẩm chơi bóng chày đáng tin cậy? Chúng tôi đã phát triển bộ dụng cụ này cho các tài năng bóng chày nhí với một quả bóng mềm và gậy được đệm mút xốp dày 58.5 cm.', N'BoBA100.jpeg', 745000, 0, 0, 0, 0, 100),
(4, N'Gậy chơi bóng chày Big Hit dành cho trẻ em - Đỏ', N'Thích hợp cho người mới chơi để đảm bảo an toàn. Sản phẩm , này phù hợp cho trẻ từ 6 tuổi, trở lên . Các nhà thiết kế của chúng tôi đã phát triển gậy chơi bóng chày 58,5 cm này với kết cấu mềm để bạn có thể dễ dàng bắt đầu chơi môn thể thao này.', N'Gaytreem.jpeg', 245000, 0, 0, 0, 0, 100),
(5, N'Giày cầu lông 530 cho nữ - Tím nhạt', N'Giày cầu lông dành cho người chơi trình độ trung bình, có độ giảm chấn tốt, thân trên nhẹ và thoáng khí, sử dụng thoải mái trên sân cũng như ngoài sân. Kết hợp giữa độ thoáng khí và khả năng giảm chấn, phù hợp với người chơi cấp độ trung bình muốn tập luyện trên sân tập.', N'Giay530.jpeg', 975000, 0, 0, 0, 0, 100),
(5, N'Vợt cầu lông BR 560 LITE cho người lớn - Hồng', N'Vợt cầu lông dành cho người chơi trình độ trung bình muốn có vợt nhẹ và dễ thao tác. Vợt cầu lông có trọng lượng nhẹ này rất dễ thao tác.', N'VotBR560.jpeg', 925000, 0, 0, 0, 0, 100),
(5, N'Hộp 3 quả cầu lông nhựa tốc độ trung bình PSC 100 - Trắng/Xanh lá/Cam', N'Dành cho người mới tập chơi cầu lông muốn tìm quả cầu bền chắc Quả cầu lông nhựa này có quỹ đạo bay ổn định nhờ có thân cầu bằng nhựa. Một chút màu sắc nổi bật giúp bạn dễ quan sát quả cầu hơn trong khi chơi.', N'Hopcaulong.jpeg', 125000, 0, 0, 0, 0, 100),
(5, N'Gói 3 đôi tất thể thao cổ thấp RS 100 - Trắng', N'Tất thể thao dành cho người mới tập chơi tennis muốn tìm mua tất thoải mái và bền bỉ cho môn thể thao này. Sản phẩm không áp dụng chính sách đổi trả vì lý do an toàn và vệ sinh. Tất nhiều cotton cực kỳ phù hợp để học chơi tennis.Bán theo gói 3 đôi.', N'TatRS100.jpeg', 99000, 0, 0, 0, 0, 100),
(5, N'Băng tay tennis TP 100 - Xanh navy', N'Dành cho tennis hoặc các môn thể thao dùng vợt khác dưới trời nóng. Có thể sử dụng để thấm mồ hôi trên mặt. Băng đeo cổ tay tennis Artengo rất thiết thực và có thể ngăn mồ hôi chảy xuống cánh tay, đảm bảo tay cầm vợt chắc chắn nhất.', N'Bangtay.jpeg', 145000, 0, 0, 0, 0, 100),
(5, N'Băng trán thể thao - Đen', N'Để chơi tennis hoặc các môn thể thao dùng vợt khác khi trời nóng. Dải buộc đầu thể thao này giúp thấm hút mồ hôi từ trán để bạn không bị cản trở khi chơi tennis. Được làm từ chất liệu rất thoải mái.', N'Bangtran.jpeg', 99000, 0, 0, 0, 0, 100),
(5, N'Váy cầu lông 530 cho nữ - Trắng', N'Váy cầu lông dành cho người chơi cấp độ trung bình tập cầu lông thường xuyên. Váy 530 có mức giá tốt nhất được thiết kế dành riêng cho môn cầu lông, khô nhanh, thoáng mát, nhẹ nhàng và chuyển động thoải mái.', N'Vaycaulong.jpeg', 325000, 0, 0, 0, 0, 100),
(5, N'Túi đựng vợt cầu lông BL 500 cho người lớn - Đen', N'Túi đựng vợt cầu lông dành cho người chơi cấp độ trung bình đang tìm kiếm một chiếc túi nhiều ngăn để dễ vận chuyển vật dụng cầu lông. Túi được thiết kế để dễ vận chuyển với nhiều ngăn.', N'Tuidungvot.jpeg', 325000, 0, 0, 0, 0, 100),
(5, N'Áo thun cầu lông thông thoáng 530 cho nữ - Xanh dương/Hồng', N'Áo thun dành cho người chơi cấp độ trung bình thường xuyên tập luyện cầu lông. Áo thun 530 có mức giá tốt nhất được thiết kế dành riêng cho môn cầu lông, khô nhanh, thoáng mát, nhẹ nhàng và chuyển động thoải mái.Có mẫu tương tự cho nam để làm đồng phục đội.', N'Aothun530.jpeg', 325000, 0, 0, 0, 0, 100),
(5, N'Quần short cầu lông LITE 560 cho nam - Xanh lá', N'Quần short dành cho người chơi cầu lông trung bình khá muốn tìm sản phẩm kỹ thuật để tập luyện thường xuyên. Quần short kỹ thuật này được làm từ vải nhẹ, thoáng khí để đảm bảo chuyển động thoải mái. Kết hợp với áo thun để có set đồ hoàn chỉnh.Có kiểu dáng tương tự cho nữ để làm đồng phục nhóm.', N'QuanLITE560.jpeg', 425000, 0, 0, 0, 0, 100),
(5, N'Băng đeo cổ tay dài - Đen/ Trắng', N'Băng đeo cổ tay dài có khả năng thấm hút mồ hôi tối đa. Sản phẩm ngăn mồ hôi chảy xuống tay, giúp người chơi cầm vợt tốt hơn.', N'Bangdeoco.jpeg', 175000, 0, 0, 0, 0, 100),
(5, N'Lưới cầu lông Easy Set 3m - Xanh ngọc', N'Lưới cầu lông dễ dàng dựng lên để chơi cầu lông giải trí ngoài trời. Lưới cầu lông rất dễ lắp ráp và tháo rời, thích hợp để chơi cầu lông với gia đình hoặc bạn bè. Bộ cầu lông bán kèm 2 vợt & 2 quả cầu lông.', N'Luoicaulong.jpeg', 1295000, 0, 0, 0, 0, 100)
GO

INSERT INTO admin_account values('admin','root')
GO

INSERT INTO user_account (user_username,user_password,user_gender,user_email,user_phonenumber,user_address,user_firstname,user_lastname,user_member_tier,user_point)
values('thongloki123','thongloki123',N'Nam','pv198357@gmail.com','0340452691',N'140 Lê Trọng Tấn',N'VINH',N'PHAN',N'Đồng',0)
GO

CREATE TRIGGER trg_update_is_paid
ON user_order
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(is_payment) OR UPDATE(is_delivered)
    BEGIN
        UPDATE user_order
        SET is_paid = 1
        FROM inserted
        WHERE user_order.user_order_id = inserted.user_order_id
              AND (inserted.is_payment = 1 OR inserted.is_delivered = 1);
    END
END;
GO

-- Tạo trigger để cập nhật is_payment sau 7 ngày giao hàng
CREATE TRIGGER tr_UpdateIsPayment
ON user_order
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UpdatedUserOrderId INT;

    SELECT @UpdatedUserOrderId = user_order_id
    FROM INSERTED;

    IF EXISTS (
        SELECT 1
        FROM user_order
        WHERE user_order_id = @UpdatedUserOrderId
            AND is_delivered = 1
            AND is_payment = 0
            AND is_paid = 0
            AND DATEDIFF(DAY, order_time, GETDATE()) >= 7
    )
    BEGIN
        UPDATE user_order
        SET is_payment = 1
        WHERE user_order_id = @UpdatedUserOrderId;
    END
END;
GO
