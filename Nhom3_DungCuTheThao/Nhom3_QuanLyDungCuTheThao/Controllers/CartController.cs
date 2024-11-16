using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Nhom3_QuanLyDungCuTheThao.Models;
using PayPal.Api;

namespace Nhom3_QuanLyDungCuTheThao.Controllers
{
    public class CartController : Controller
    {
        //
        // GET: /Cart/
        int flagPayment = 0;
        static FormCollection gobal;
        public ActionResult Index()
        {
            ViewBag.sum = GetCart().Sum(pc => (pc.Price - pc.Discount) * pc.Amount);
            ViewBag.amount = GetCart().Sum(pc => pc.Amount);
            return View(GetCart());
        }

        public ActionResult OrderList()
        {
            return View();
        }

        public List<InCartProduct> GetCart()
        {
            if (Session["cart"] == null)
                return new List<InCartProduct>();
            return Session["cart"] as List<InCartProduct>;
        }

        public ActionResult AddProductIntoCart(int id)
        {
            List<InCartProduct> products = GetCart();
            InCartProduct ICPrd = products.Find(prd => prd.Id == id);
            if (ICPrd == null)
            {
                products.Add(new InCartProduct(id));
            }
            else
            {
                ICPrd.Amount++;
            }
            Session["cart"] = products;
            return RedirectToAction("Details", "Product", new {ID = id});
        }

        [HttpPost]
        public ActionResult ChangeProductAmount(FormCollection c)
        {
            List<InCartProduct> products = GetCart();
            foreach(InCartProduct icp in products)
            {
                icp.Amount = int.Parse(Request[(icp.Id).ToString()]);
            }
            Session["cart"] = products;
            return RedirectToAction("Index", "Cart");
        }

        public ActionResult DeleteProduct(int id)
        {
            List<InCartProduct> products = GetCart();
            products.RemoveAll(product => product.Id == id);
            Session["cart"] = products;
            return RedirectToAction("Index", "Cart");
        }

        public ActionResult RequestOrder()
        {
            ViewBag.sum = GetCart().Sum(pc => (pc.Price * pc.Amount) - (pc.Price * pc.Discount));
            ViewBag.amount = GetCart().Sum(pc => pc.Amount);
            return View(GetCart());
        }
        public ActionResult TotalCart()
        {
            List<InCartProduct> products = GetCart();
            int count;
            if (products.Count == 0)
            {
                count = 0; 
            }
            else
            {
                count = products.Count;
            }
            ViewBag.Count = count;
            return View();
        }
        [HttpPost]
        public ActionResult SubmitOrder(FormCollection c)
        {
            using (var dbContext = new SHSDBDataContext())
            {
                if (GetCart().Count != 0)
                {
                    List<InCartProduct> products = GetCart();
                    user_order uo = new user_order();
                    if (Session["currentUser"] != null)
                    {
                        uo.user_account_id = (Session["currentUser"] as user_account).user_account_id;
                    }                    
                    uo.order_time = DateTime.Now;
                    uo.is_processed = false; // đang xử lý
                    uo.is_delivered = false; // chưa giao
                    string payment = Request["paymentMethod"];
                    if(payment=="COD")
                    {
                        uo.is_payment = false;
                        uo.is_paid = false;
                    }
                    else
                    { 
                            uo.is_payment = true;
                            uo.is_paid = true;                    
                    }                  
                    uo.user_order_buyer_name = Request["Order_owner_name"];
                    uo.user_order_address = Request["Order_owner_address"];
                    uo.user_order_email = Request["Order_owner_email"];
                    uo.user_order_phonenumber = Request["Order_owner_phone"];
                    uo.order_total_value = GetCart().Sum(pc => (pc.Price * pc.Amount)-(pc.Price*pc.Discount));
                    dbContext.user_orders.InsertOnSubmit(uo);
                    dbContext.SubmitChanges();
                    foreach (InCartProduct product in products)
                    {
                        // insert thông tin khách hàng mua
                        user_order_product uop = new user_order_product();
                        uop.product_id = product.Id;
                        uop.user_order_id = uo.user_order_id;
                        uop.product_name = product.Name;
                        uop.order_product_amount = product.Amount;
                        dbContext.user_order_products.InsertOnSubmit(uop);
                        // cật nhật số lượng sản phẩm, số lượng mua
                        product prd = dbContext.products.SingleOrDefault(p => p.product_id == product.Id);
                        prd.product_inventory -= product.Amount;
                        prd.product_bought_count += product.Amount;
                    }

                    dbContext.SubmitChanges();
                    Session.Remove("cart");
                }
            }
            TempData["submitSucceed"] = 1;
            return RedirectToAction("Index", "Home");
        }
      public double total_Money()
        {
            return (double)GetCart().Sum(pc => (pc.Price * pc.Amount) - (pc.Price * pc.Discount));
        }
        public ActionResult SubmitSucceed()
        {
          
            return PartialView();
        }

        public ActionResult FailureView()
        {
            flagPayment = 0;
            return View();
        }
        public ActionResult SuccessView()
        {       
            return View();
        }
        // tạo redirec đến trang thanh toán thành công
        public ActionResult PaymentWithPaypal( FormCollection f, string Cancel = null)
        {
            // Lấy APIContext từ cấu hình PayPal
            APIContext apiContext = PaypalConfiguration.GetAPIContext();
    
            try
            {   
              
                string payerId = Request.Params["PayerID"];
                if (string.IsNullOrEmpty(payerId))
                {
                    // Đây là lần đầu tiên người dùng bắt đầu quá trình thanh toán
                    // Tạo URL chuyển hướng và GUID để lưu trữ paymentID vào Session
                    string baseURI = Request.Url.Scheme + "://" + Request.Url.Authority + "/Cart/PaymentWithPayPal?";               
                    var guid = Convert.ToString((new Random()).Next(100000));

                    // Gọi phương thức CreatePayment để tạo thanh toán
                    var createdPayment = this.CreatePayment(apiContext, baseURI + "guid=" + guid);

                    // Lấy địa chỉ URL chuyển hướng từ kết quả tạo thanh toán
                    var links = createdPayment.links.GetEnumerator();
                    string paypalRedirectUrl = null;
                    while (links.MoveNext())
                    {
                        Links lnk = links.Current;
                        if (lnk.rel.ToLower().Trim().Equals("approval_url"))
                        {
                            
                            paypalRedirectUrl = lnk.href;
                        }
                    }
                    gobal = f; // lưu thông tin người dùng vào local
                    // Lưu paymentID vào Session với key là GUID
                    Session.Add(guid, createdPayment.id);
                    return Redirect(paypalRedirectUrl);
                }
                else
                {
                    // Đây là phản hồi từ trang thanh toán PayPal
                    // Lấy GUID từ tham số yêu cầu
                    var guid = Request.Params["guid"];
                    // Gọi phương thức ExecutePayment để hoàn tất thanh toán
                    var executedPayment = ExecutePayment(apiContext, payerId, Session[guid] as string);
                    // Nếu thanh toán không được xác nhận, hiển thị trang thất bại
                    if (executedPayment.state.ToLower() != "approved")
                    {
                        return View("FailureView");
                    }
                }
            }
            catch (Exception ex)
            {
               // throw ex;
               return View("FailureView");
            }

            using (var dbContext = new SHSDBDataContext())
            {
                if (GetCart().Count != 0)
                {
                    List<InCartProduct> products = GetCart();
                    user_order uo = new user_order();
                    if (Session["currentUser"] != null)
                    {
                        uo.user_account_id = (Session["currentUser"] as user_account).user_account_id;
                    }
                    uo.order_time = DateTime.Now;
                    uo.is_processed = false; // đang xử lý
                    uo.is_delivered = false; // chưa giao               
                    uo.is_payment = true;
                    uo.is_paid = true;
                    uo.user_order_buyer_name = gobal["Order_owner_name"];
                    uo.user_order_address = gobal["Order_owner_address"];
                    uo.user_order_email = gobal["Order_owner_email"];
                    uo.user_order_phonenumber = gobal["Order_owner_phone"];
                    uo.order_total_value = GetCart().Sum(pc => (pc.Price * pc.Amount) - (pc.Price * pc.Discount));
                    dbContext.user_orders.InsertOnSubmit(uo);
                    dbContext.SubmitChanges();
                    foreach (InCartProduct product in products)
                    {
                        // insert thông tin khách hàng mua
                        user_order_product uop = new user_order_product();
                        uop.product_id = product.Id;
                        uop.user_order_id = uo.user_order_id;
                        uop.product_name = product.Name;
                        uop.order_product_amount = product.Amount;
                        dbContext.user_order_products.InsertOnSubmit(uop);
                        // cật nhật số lượng sản phẩm, số lượng mua
                        product prd = dbContext.products.SingleOrDefault(p => p.product_id == product.Id);
                        prd.product_inventory -= product.Amount;
                        prd.product_bought_count += product.Amount;
                    }

                    dbContext.SubmitChanges();
                    Session.Remove("cart");
                }
            }
            TempData["submitSucceed"] = 1;
            // Nếu thanh toán thành công, hiển thị trang thành công
            return View("SuccessView");
        }
        private PayPal.Api.Payment payment;
        // thực hiện trừ tiền 
        private Payment ExecutePayment(APIContext apiContext, string payerId, string paymentId)
        {
            // Tạo đối tượng PaymentExecution để thực hiện thanh toán
            var paymentExecution = new PaymentExecution()
            {
                payer_id = payerId
            };
            // Tạo đối tượng Payment để xác định thanh toán cần thực hiện
            this.payment = new Payment()
            {
                id = paymentId
            };

            // Gọi API để thực hiện thanh toán và trả về đối tượng Payment đã thực hiện
            return this.payment.Execute(apiContext, paymentExecution);
        }

        // tính tổng tiền sản phẩm
        private Payment CreatePayment(APIContext apiContext, string redirectUrl)
        {
            // Tạo danh sách sản phẩm để thêm vào thanh toán
            var itemList = new ItemList()
            {
                items = new List<Item>()
            };
            // Lấy thông tin sản phẩm từ giỏ hàng (Session["cart"])
            var products = Session["cart"] as List<InCartProduct>;
            foreach (var item in products)
            {       
                // Thêm từng sản phẩm vào danh sách
                itemList.items.Add(new Item()
                {
                    name = item.Name,
                    currency = "USD",
                    price = item.Price.ToString(),
                    quantity = item.Amount.ToString(),
                    sku = item.Id.ToString()
                });
            }

            // Tạo đối tượng Payer đại diện cho phương thức thanh toán (paypal)
            var payer = new Payer()
            {
                payment_method = "paypal"
            };
            // Cấu hình RedirectUrls cho quá trình chuyển hướng người dùng
            var redirUrls = new RedirectUrls()
            {
                cancel_url = redirectUrl + "&Cancel=true",
                return_url = redirectUrl
            };

            // Tạo đối tượng Details để chứa thông tin về thuế, vận chuyển, và tổng cộng
            var details = new Details()
            {
                tax = "0",
                shipping = "0",
                subtotal = GetCart().Sum(pc => pc.Price * pc.Amount).ToString("0.00") // Tổng giá trị sản phẩm
            };
            // Tạo đối tượng Amount chứa thông tin về tổng cộng
            var amount = new Amount()
            {
                currency = "USD",
                total = details.subtotal, // Tổng giá trị đơn hàng
                details = details
            };

            // Tạo danh sách Transaction với mô tả và số hóa đơn
            var transactionList = new List<Transaction>();
            var paypalOrderId = DateTime.Now.Ticks;
            transactionList.Add(new Transaction()
            {
                description = $"Invoice #{paypalOrderId}",
                invoice_number = paypalOrderId.ToString(), //Generate an Invoice No    
                amount = amount,
                item_list = itemList
            });

            // Tạo đối tượng Payment cuối cùng
            this.payment = new Payment()
            {
                intent = "sale",
                payer = payer,
                transactions = transactionList,
                redirect_urls = redirUrls
            };

            // Gọi API để tạo thanh toán và trả về đối tượng Payment đã tạo
            return this.payment.Create(apiContext);
        }
    }
}
